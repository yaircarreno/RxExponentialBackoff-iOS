# RxExponentialBackoff Pattern implemented in iOS using RxSwift

This repository contains an example of the retry pattern implementation in iOS applications.
You can also find the Android implementation at [RxExponentialBackoff-Android](https://github.com/yaircarreno/RxExponentialBackoff-Android)

## Articles

- [Exponential Backoff and Retry Patterns in Mobile](https://www.yaircarreno.com/2021/03/exponential-backoff-and-retry-patterns.html)


## Component Diagram

![RxExponentialBackoff Pattern](https://github.com/yaircarreno/RxExponentialBackoff-iOS/blob/main/Screenshots/exb_retry_pattern.png)

## Implementation

With constant incremental time window approach:

```swift
private func constantRetry(_ maxiTimeRetry: Int) {
    operationWithPossibleFailure()
        .retry{ errors in errors
            .do(onNext: { ignored in print("retrying...") })
            .delay(.seconds(2), scheduler: self.serialScheduler)
            .take(maxiTimeRetry)
            .concat(Observable.error(SampleError()))}
        .catch({ error in Observable.error(error) })
        .subscribe(on: serialScheduler)
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { user in self.logs(user, true) },
                    onError: { error in self.logs(error, false) },
                    onCompleted: { print("completed") } )
        .disposed(by: disposeBag)
}
```
With exponential and random increment time window approach:

```swift
private func exponentialWithRandomRetry(_ maxiTimeRetry: Int) {
    operationWithPossibleFailure()
        .retry{ errors in errors
            .map{ errors in 1 }
            .scan(0){ attempt, next in return attempt + next }
            .map{ attempt in [attempt, self.exponentialBackoff(attempt, true)] }
            .do(onNext: {pair in self.printCurrentTime(pair[0], pair[1])})
            .map{ pair in pair[1] }
            .flatMap{delayTime in Observable.just(delayTime)
                .delay(.seconds(delayTime), scheduler: self.serialScheduler)}
            .take(maxiTimeRetry)
            .concat(Observable.error(SampleError()))}
        .catch({ error in Observable.error(error) })
        .subscribe(on: serialScheduler)
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { user in self.logs(user, true) },
                    onError: { error in self.logs(error, false) },
                    onCompleted: { print("completed") } )
        .disposed(by: disposeBag)
}
```

Function to calculate the delay time used in the pattern retry.

```swift
private func exponentialBackoff(_ attempt: Int, _ withRandom: Bool) -> Int {
    let min = -1000
    let max = 1000
    if (withRandom) {
        let random_number = Int.random(in: min..<max)
        let random_number_milliseconds = round(Double(random_number) * 0.001)
        return Int((pow(Double(2), Double(attempt))) + random_number_milliseconds)
    } else {
        return Int(pow(Double(2), Double(attempt)))
    }
}
```

## Demo

![RxExponentialBackoff Pattern](https://github.com/yaircarreno/RxExponentialBackoff-iOS/blob/main/Screenshots/demo-ios-retry-pattern.gif)


## Versions of IDEs and technologies used.

- Xcode 12.4 - Swift 5
- RxSwift 6
- Storyboards
- Cocoapods


