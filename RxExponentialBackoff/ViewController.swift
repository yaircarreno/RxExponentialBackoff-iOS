//
//  ViewController.swift
//  RxExponentialBackoff
//
//  Created by Yair Carreno on 2/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    let serialScheduler = SerialDispatchQueueScheduler(qos: .default)
    var activityIndicator = UIActivityIndicatorView(style: .large)

    struct SampleError: Swift.Error {}

    @IBOutlet weak var immediateButton: UIButton!
    @IBOutlet weak var constantButton: UIButton!
    @IBOutlet weak var exponentialButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    @IBAction func immediateRetry(_ sender: Any) {
        prepateUIForCall()
        immediateRetry(3)
    }
    
    @IBAction func constantRetry(_ sender: Any) {
        prepateUIForCall()
        constantRetry(3)
    }

    @IBAction func exponentialRetry(_ sender: Any) {
        prepateUIForCall()
        exponentialRetry(3)
    }

    @IBAction func exponentialWithRandomRetry(_ sender: Any) {
        prepateUIForCall()
        exponentialWithRandomRetry(3)
    }

    private func immediateRetry(_ maxiTimeRetry: Int) {
        operationWithPossibleFailure()
            .do(afterError: {ignored in print("retrying...")})
            .retry(maxiTimeRetry)
            .catch({ error in Observable.error(error)
                    .do(onError: { _ in print(error) }) })
            .subscribe(on: serialScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { user in self.logs(user, true) },
                       onError: { error in self.logs(error, false) },
                       onCompleted: { print("completed") } )
            .disposed(by: disposeBag)
    }

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

    private func exponentialRetry(_ maxiTimeRetry: Int) {
        operationWithPossibleFailure()
            .retry{ errors in errors
                .map{ errors in 1 }
                .scan(0){ attempt, next in return attempt + next }
                .map{ attempt in [attempt, self.exponentialBackoff(attempt, false)] }
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

    private func operationWithPossibleFailure() -> Observable<Any> {
        return Observable.error(SampleError())
    }

    private func printCurrentTime(_ attempt: Int, _ timeElapsed: Int) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        print("Retrying \(attempt) occurs at \(dateString) time, after \(timeElapsed) seconds")
    }

    private func logs(_ response: Any, _ success: Bool) {
        if (success) {
            print("next: \(response)")
        } else {
            print("error: \(response)")
        }
        self.activityIndicator.stopAnimating()
        enableButtons(true)
    }

    private func setUpUI() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func prepateUIForCall() {
        activityIndicator.startAnimating()
        enableButtons(false)
    }

    private func enableButtons(_ enable: Bool) {
        immediateButton.isEnabled = enable
        constantButton.isEnabled = enable
        exponentialButton.isEnabled = enable
        randomButton.isEnabled = enable
    }
}

