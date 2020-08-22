//
//  ViewController.swift
//  Warmingup
//
//  Created by 黑田光 on 2020/08/22.
//  Copyright © 2020 Hikaru Kuroda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var freeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet var greetingButton: [UIButton]!
    
    let disposeBag = DisposeBag()
    let lastSelectedGreeting: BehaviorRelay<String> = BehaviorRelay<String>(value: "こんにちは")
    
    enum State: Int {
        case useButtons
        case useTextField
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameObservable: Observable<String?> = nameTextField.rx.text.asObservable()
        let freeObservable: Observable<String?> = freeTextField.rx.text.asObservable()
        
        let freewordWithNameObservable: Observable<String?> = Observable.combineLatest(nameObservable, freeObservable) {
            (string1: String?, string2: String?) in
            return string1! + string2!
        }
        freewordWithNameObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
        
        let segmentControlObservable: Observable<Int> = stateSegmentedControl.rx.value.asObservable()
        let stateObservable: Observable<State> = segmentControlObservable.map { (selectedIndex: Int) -> State in
            return State(rawValue: selectedIndex)!
        }
        
        let greetingTextFieldEnabledObservable: Observable<Bool> = stateObservable.map { (state: State) -> Bool in
            return state == .useTextField
        }
        greetingTextFieldEnabledObservable.bind(to: freeTextField.rx.isEnabled).disposed(by: disposeBag)
        
        let buttonsEnabledObservable: Observable<Bool> = greetingTextFieldEnabledObservable.map { (greetingEnabled: Bool) -> Bool in
            return !greetingEnabled
        }
        
        greetingButton.forEach { (button) in
            buttonsEnabledObservable.bind(to: button.rx.isEnabled).disposed(by: disposeBag)
            
            button.rx.tap.subscribe(onNext: {(nothing: Void) in
                self.lastSelectedGreeting.accept(button.currentTitle!)
            }).disposed(by: disposeBag)
        }
        
        let predefinedGreetingObservable: Observable<String> = lastSelectedGreeting.asObservable()
        let finalGreetingObservable: Observable<String> = Observable.combineLatest(stateObservable, freeObservable, predefinedGreetingObservable, nameObservable) { (state: State, freeword: String?, predefinedGreeting: String, name: String?) -> String in

            switch state {
                case .useTextField: return freeword! + name!
                case .useButtons: return predefinedGreeting + name!
            }
        }
        finalGreetingObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
        
        
    }


}

