//
//  RespitoryClassifierPub.swift
//  FaceBit Companion
//
//  Created by blaine on 2/11/21.
//

import Foundation

import Foundation
import Combine
import SQLite3
import CoreML
import Accelerate
import GRDB

class RespitoryClassifierViewModel: ObservableObject {
    
    enum Classification: Int, CaseIterable, Identifiable {
        case maskOff = 0
        case normalBreathing
        case talking
        case cough
        case unknown
        
        var label: String {
            switch self {
            case .maskOff: return "Mask Off"
            case .normalBreathing: return "Normal Breathing"
            case .talking: return "Talking"
            case .cough: return "Coughing"
            case .unknown: return "Unknown"
            }
        }
        
        var id: Int { return self.rawValue }
    }
    
    private let appDatabase: AppDatabase
    private let timeOffset: TimeInterval
    
    private let baseFrequency = 17
    private var sampleSize: Int { return baseFrequency * 3 }
    
    private var observer: TransactionObserver?
    
    private let queryDuration: TimeInterval = 5
    private var model: RespiratoryClassifier {
        let config = MLModelConfiguration()
        return try! RespiratoryClassifier(configuration: config)
    }
    
    @Published var classification: Classification = .unknown
    
    init(appDatabase: AppDatabase, timeOffset: TimeInterval=20) {
        self.appDatabase = appDatabase
        self.timeOffset = timeOffset
        
        try? appDatabase.dbWriter.read { (db) in
            self.fetchData(with: db)
        }
        
        self.observer = try? observation().start(in: appDatabase.dbWriter, onChange: { (db) in
            self.fetchData(with: db)
        })
    }
    
    func observation() -> DatabaseRegionObservation {
        return DatabaseRegionObservation(
            tracking: TimeSeriesDataRead
                .filter(TimeSeriesDataRead.Columns.dataType == TimeSeriesDataRead.DataType.pressure)
        )
    }
    
    func fetchData(with db: Database) {
        do {
            let endDate = Date().addingTimeInterval(-self.timeOffset)
            let startDate = endDate.addingTimeInterval(-self.queryDuration)
            
            let measurements = try TimeSeriesMeasurement
                    .filter(TimeSeriesMeasurement.Columns.date > startDate)
                    .filter(TimeSeriesMeasurement.Columns.date < endDate)
                    .order(TimeSeriesMeasurement.Columns.date.desc)
                    .including(required: TimeSeriesMeasurement.dataRead)
                    .asRequest(of: TimeSeriesMeasurementInfo.self)
                    .fetchAll(db)
            
            self.infer(measurements)
        } catch {
            PersistanceLogger.error("unable to complete query: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Inference
    private func infer(_ measurements: [TimeSeriesMeasurementInfo]) {
        let tempMeasurements = measurements.filter({ $0.dataRead.dataType == .temperature })
        let tempFreqMean = tempMeasurements.reduce(0.0, { return $0 + $1.dataRead.frequency }) / Double(tempMeasurements.count)
        let tempStartTime = tempMeasurements.first?.timeseriesMeasurement.date ?? Date()
        let tempEndTime = tempMeasurements.last?.timeseriesMeasurement.date ?? Date()
        
        let pressureMeasurements = measurements.filter({ $0.dataRead.dataType == .pressure })
        let pressureFreqMean = pressureMeasurements.reduce(0.0, { return $0 + $1.dataRead.frequency }) / Double(pressureMeasurements.count)
        let pressureStartTime = pressureMeasurements.first?.timeseriesMeasurement.date ?? Date()
        let pressureEndTime = pressureMeasurements.last?.timeseriesMeasurement.date ?? Date()
        
        let tempSignal: [Float] = tempMeasurements.map({ Float($0.timeseriesMeasurement.value) })
        let pressureSignal: [Float] = pressureMeasurements.map({ Float($0.timeseriesMeasurement.value) })
        
        // check dates of queried time series data
        guard
            Calendar.current.compare(tempStartTime, to: pressureStartTime, toGranularity: .second) == .orderedSame,
            Calendar.current.compare(tempEndTime, to: pressureEndTime, toGranularity: .second) == .orderedSame
        else{
            InferenceLogger.debug("Incomplete Signal: Dates")
            return
        }
        
        // check number of samples of time series data
        guard
            Double(tempSignal.count) >= (tempFreqMean * queryDuration) - 5.0,
            Double(pressureSignal.count) >= (pressureFreqMean * queryDuration) - 5.0
        else {
            InferenceLogger.debug("Incomplete Signal: Number of Samples")
            return
        }
        
        // pre-process the data: [resample to min freq, demean]
        let temp = demean(
            Array(
                resample(
                    tempSignal,
                    startTime: tempStartTime,
                    endTime: tempEndTime,
                    freq: baseFrequency
                ).prefix(sampleSize)
            )
        )
        
        let pressure = demean(
            Array(
                resample(
                    pressureSignal,
                    startTime: pressureStartTime,
                    endTime: pressureEndTime,
                    freq: baseFrequency
                ).prefix(sampleSize)
            )
        )
        
        // prepare input vector
        guard let inputArray = try? MLMultiArray(shape: [1,2,sampleSize as NSNumber], dataType: .float32) else {
            return
        }
        
        let combined = temp + pressure
        for (idx, e) in combined.enumerated() {
            inputArray[idx] = NSNumber(value: e)
        }
        
        let input = RespiratoryClassifierInput(input_input: inputArray)
        
        // predict
        guard let predMLArray = try? model.prediction(input: input).Identity else {
            return
        }
        
        let pred = Array(
            UnsafeBufferPointer(
                start: predMLArray.dataPointer.bindMemory(
                    to: Float.self,
                    capacity: predMLArray.count
                ),
                count: predMLArray.count
            )
        )
        
        // determine a classification based on 90% threshold of confidence
        var cls: Classification = .unknown
        defer {
            InferenceLogger.info("Respirtory Classification: \(cls.label)")
            DispatchQueue.main.async {
                self.classification = cls
            }
        }
        
        guard let val = pred.max(), val > 0.9 else { return }
        
        switch pred.firstIndex(of: val) {
        case 0: cls = .maskOff
        case 1: cls = .normalBreathing
        case 2: cls = .talking
        case 3: cls = .cough
        default: return
        }
        
         
        
    }
    
    // MARK: - Helpers
    private func demean(_ x: [Float]) -> [Float] {
        let sum = x.reduce(0, { a, b in
            return a + b
        })
        let mean = Float(sum) / Float(x.count)
        
        var output = [Float](repeating: 0.0, count: x.count)
        for (idx, v) in x.enumerated() {
            output[idx] = v - mean
        }
        
        return output
    }
    
    private func resample(_ signal: [Float], startTime: Date, endTime: Date, freq: Int=17) -> [Float] {
        let timeDiff: Double = abs(endTime.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate)
        
        let filterLength: vDSP_Length = 2
        let decimationFactor: vDSP_Stride = 1
        let filter = [Float](repeating: 1/Float(filterLength), count: Int(filterLength))
        
        let n = vDSP_Length(Double(freq) * timeDiff)
        
        var outputSignal = [Float](repeating: 0, count: Int(n))
        vDSP_desamp(
            signal,
            decimationFactor,
            filter,
            &outputSignal,
            n,
            filterLength
        )
        return outputSignal
    }
    
}
