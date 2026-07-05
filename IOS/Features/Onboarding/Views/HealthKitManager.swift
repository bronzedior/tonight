import Foundation
import HealthKit

import HealthKit

final class HealthKitManager {

    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private init() {}
    
    func requestAuthorization(
        completion: @escaping (Bool) -> Void
    ) {

        guard HKHealthStore.isHealthDataAvailable() else {

            completion(false)

            return

        }

        guard

            let heartRate = HKObjectType.quantityType(
                forIdentifier: .heartRate
            ),

            let walkingSpeed = HKObjectType.quantityType(
                forIdentifier: .walkingSpeed
            ),

            let walkingAsymmetry = HKObjectType.quantityType(
                forIdentifier: .walkingAsymmetryPercentage
            ),

            let doubleSupport = HKObjectType.quantityType(
                forIdentifier: .walkingDoubleSupportPercentage
            )

        else {

            completion(false)

            return

        }

        let readTypes: Set<HKObjectType> = [

            heartRate,

            walkingSpeed,

            walkingAsymmetry,

            doubleSupport

        ]

        healthStore.requestAuthorization(
            toShare: [],
            read: readTypes
        ) { success, _ in

            DispatchQueue.main.async {

                completion(success)

            }

        }

    }

}
