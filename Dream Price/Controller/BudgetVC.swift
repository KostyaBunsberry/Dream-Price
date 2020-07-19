//
//  BudgetVC.swift
//  Dream Price
//
//  Created by Kostya Bunsberry on 14.07.2020.
//

import UIKit

protocol TransportUpDelegate {
    func transportUp(string: String)
}

class BudgetVC: UIViewController, BudgetDelegate {
    
    // TODO: Получение категорий из DB
    
    let categories: [Category] = [
        Category(id: 0, type: .earning, title: "💼 Работа"),
        Category(id: 0, type: .spending, title: "☕️ Кофе"),
        Category(id: 1, type: .spending, title: "🥑 Продукты"),
        Category(id: 0, type: .budget, title: "📱 Приложуха"),
        Category(id: 1, type: .budget, title: "🌙 Мечта"),
        Category(id: 0, type: .manage, title: "Изменить...")
    ]
    
    var categoriesShown: [Category] = []

    public static var currentTransaction: String = "-"
    
    public static var delegateUp: TransportUpDelegate?
    
    @IBOutlet weak var budgetsViewContainer: UIView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsSetup()
        updateCategories(transaction: "-")
    }
    
    // MARK: Buttons setup
    
    func buttonsSetup() {
        removeButton.imageView?.contentMode = .scaleAspectFit
        removeButton.setImage(removeButton.image(for: .normal)?.withTintColor(.label, renderingMode:.alwaysOriginal), for: .normal)
        removeButton.setImage(removeButton.image(for: .normal)?.withTintColor(.quaternaryLabel, renderingMode: .alwaysOriginal), for: .highlighted)
        
        doneButton.setImage(doneButton.image(for: .normal)?.withTintColor(.label, renderingMode:.alwaysOriginal), for: .normal)
        doneButton.setImage(doneButton.image(for: .normal)?.withTintColor(.quaternaryLabel, renderingMode:.alwaysOriginal), for: .highlighted)
        doneButton.setImage(doneButton.image(for: .normal)?.withTintColor(.secondaryLabel, renderingMode:.alwaysOriginal), for: .disabled)
        
        removeButton.isEnabled = false
        doneButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BudgetPVC, segue.identifier == "embedWindow" {
            vc.budgetDelegate = self
        }
    }
    
    // MARK: Categories Update
    
    func updateCategories(transaction: String) {
        categoriesShown.removeAll()
        
        switch transaction {
        case "-": do {
                for el in self.categories {
                    if el.type != .earning {
                        self.categoriesShown.append(el)
                    }
                }
            }
            case "+": do {
                for el in self.categories {
                    if el.type != .spending {
                        self.categoriesShown.append(el)
                    }
                }
            }
            default: break
        }
        
        categoriesCollectionView.reloadData()
    }
    
}

// MARK:  Buttons Interaction

extension BudgetVC {
    
    @IBAction func numberOneButton(_ sender: Any) { sendAction(action: "1") }
    
    @IBAction func numberTwoButton(_ sender: Any) { sendAction(action: "2") }
    
    @IBAction func numberThreeButton(_ sender: Any) { sendAction(action: "3") }
    
    @IBAction func numberFourButton(_ sender: Any) { sendAction(action: "4") }
    
    @IBAction func numberFiveButton(_ sender: Any) { sendAction(action: "5") }
    
    @IBAction func numberSixButton(_ sender: Any) { sendAction(action: "6") }
    
    @IBAction func numberSevenButton(_ sender: Any) { sendAction(action: "7") }
    
    @IBAction func numberEightButton(_ sender: Any) { sendAction(action: "8") }
    
    @IBAction func numberNineButton(_ sender: Any) { sendAction(action: "9") }
    
    @IBAction func deleteButton(_ sender: Any) {
        sendAction(action: "-")
    }
    
    @IBAction func numberZeroButton(_ sender: Any) { sendAction(action: "0") }
    
    @IBAction func doneButton(_ sender: Any) {
        sendAction(action: "+")
    }
    
    // MARK: Delegate protocol
    
    func createTransaction(number: Float, budgetID: Int) {
        
        // TODO: Transactions are added to DB here
        
        if let indexPath = categoriesCollectionView.indexPathsForSelectedItems?.first {
            
            let cell = categoriesCollectionView.cellForItem(at: indexPath) as? CategoryCell
            
            if cell?.categoryType == CategoryType.spending {
                print("id-\(budgetID): Spent \(number) on \(cell!.titleLabel.text!)")
            }
            else if cell?.categoryType == CategoryType.earning {
                print("id-\(budgetID): Earned \(number) from \(cell!.titleLabel.text!)")
            }
            else if cell?.categoryType == CategoryType.budget {
                print("id-\(budgetID): Transfered \(number) from/to \(cell!.titleLabel.text!)")
            }
            
        } else {
            print("id_\(budgetID): \(number) on/from smthng...")
        }
        
        categoriesCollectionView.reloadData()
    }
    
    func sendAction(action: String) {
        BudgetVC.delegateUp?.transportUp(string: action)
    }
    
    func disableButtons() {
        removeButton.isEnabled = false
        doneButton.isEnabled = false
    }
    
    func enableButtons() {
        removeButton.isEnabled = true
        doneButton.isEnabled = true
    }
}
