//
//  BudgetPVC.swift
//  Dream Price
//
//  Created by Kostya Bunsberry on 14.07.2020.
//

import UIKit

protocol BudgetDelegate {
    func updateCategories(transaction: String, name: String)
    func createTransaction(number: Float, budgetID: String)
    func disableButtons()
    func enableButtons()
}

protocol KeyboardDelegate {
    func updateTransaction(action: String)
    func reloadItems()
}

class BudgetPVC: UIPageViewController, TransportDelegate, TransportUpDelegate {
    
    // TODO: Getting budgetItems from DB here
    
    let pagesData: [BudgetItem] = [
        BudgetItem(budgetID: UUID().uuidString, type: .project, balance: 0, name: NSLocalizedString("App", comment: "")),
        BudgetItem(budgetID: UUID().uuidString, type: .personal, balance: 2180, name: NSLocalizedString("Personal Account", comment: "")),
        BudgetItem(budgetID: UUID().uuidString, type: .dream, balance: 50000, name: NSLocalizedString("Dream", comment: ""))
    ]
    
    var budgetDelegate: BudgetDelegate?
    var keyboardDelegate: KeyboardDelegate?
    
    var currentIndex: Int = 0
    var starterIndex: Int = 0
    
    var appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appearance.pageIndicatorTintColor = UIColor.secondaryLabel
        appearance.currentPageIndicatorTintColor = UIColor.label

        self.dataSource = self
        self.delegate = self
        
        BudgetItemDataVC.delegate = self
        BudgetVC.delegateUp = self
        
        for (index, page) in pagesData.enumerated() {
            if page.type == .personal {
                starterIndex = index
            }
        }
        
        if let vc = self.pageViewController(for: starterIndex) {
            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            keyboardDelegate = vc
        }
    }
    
    // MARK: Delegate protocol
    
    func transportCurrentState(symbol: String, name: String) {
        budgetDelegate?.updateCategories(transaction: symbol, name: name)
    }
    
    func transportTransactionData(number: Float, budgetID: String) {
        budgetDelegate?.createTransaction(number: number, budgetID: budgetID)
    }
    
    func transportButtons(enabled: Int) {
        if enabled == 0 {
            budgetDelegate?.disableButtons()
        } else {
            budgetDelegate?.enableButtons()
        }
    }
    
    func transportUp(string: String) {
        keyboardDelegate?.updateTransaction(action: string)
    }
    
    func reloadItems() {
        keyboardDelegate?.reloadItems()
    }
    
    // MARK: Page View
    
    func pageViewController(for index: Int) -> BudgetItemDataVC? {
        if index < 0 || index >= pagesData.count {
            return nil
        }
        let vc = (storyboard?.instantiateViewController(withIdentifier: "BudgetItemDataVC") as! BudgetItemDataVC)
        
        vc.balance = pagesData[index].balance
        vc.nameLabelText = pagesData[index].name
        vc.budgetItemType = pagesData[index].type
        vc.index = index
        vc.budgetID = pagesData[index].budgetID
        
        self.currentIndex = index
        
        return vc
    }

}

extension BudgetPVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pagesData.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = ((viewController as? BudgetItemDataVC)?.index ?? 0) - 1
        
        DispatchQueue.main.async {
            self.keyboardDelegate = viewController as? BudgetItemDataVC
            self.transportCurrentState(symbol: ((viewController as? BudgetItemDataVC)?.changeTransactionButton.title(for: .normal))!, name: ((viewController as? BudgetItemDataVC)?.nameLabelText)!)
        }
        
        return self.pageViewController(for: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = ((viewController as? BudgetItemDataVC)?.index ?? 0) + 1
        
        DispatchQueue.main.async {
            self.keyboardDelegate = viewController as? BudgetItemDataVC
            self.transportCurrentState(symbol: ((viewController as? BudgetItemDataVC)?.changeTransactionButton.title(for: .normal))!, name: ((viewController as? BudgetItemDataVC)?.nameLabelText)!)
        }
        
        return self.pageViewController(for: index)
    }
    
}