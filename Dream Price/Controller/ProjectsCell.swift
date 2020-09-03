//
//  ProjectsCell.swift
//  Dream Price
//
//  Created by Kostya Bunsberry on 19.07.2020.
//

import UIKit
import RealmSwift

protocol ProjectDelegate {
    func openProject(id: String)
    func newProject()
}

class ProjectsCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let realm = try! Realm()
    var projects: [Project] = [Project(name: "Приложение", details: "Мое первое инди!", isFinished: false, isBudget: true, budget: 100, balance: 150, actions: []),
                               Project(name: "Повседневка", details: "", isFinished: false, isBudget: false, budget: 0, balance: 0, actions: []),
                               Project(name: "Завершенный проект", details: "", isFinished: true, isBudget: false, budget: 0, balance: 0, actions: [])]
    
    var projectsShown = [Project]()
    
    var delegate: ProjectDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
//        projects = realm.objects(RealmProject.self)
        for project in projects {
            if project.isFinished == false {
                projectsShown.append(project)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ProjectsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectsShown.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == projectsShown.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddProjectCell", for: indexPath) as! AddProjectCVCell
            
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.layer.cornerRadius = cell.frame.width / 10
            cell.addProjectLabel.textColor = UIColor(red: 0.842, green: 0.477, blue: 0.477, alpha: 1)
            cell.plusLabel.textColor = UIColor(red: 0.842, green: 0.477, blue: 0.477, alpha: 1)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCell", for: indexPath) as! ProjectCVCell
            
            if projectsShown[indexPath.row].isBudget == false {
                cell.budgetDifferenceLabel.text = ""
                cell.budgetDifferenceLabel.textColor = .clear
                cell.budgetDifferenceView.backgroundColor = .clear
            } else {
                cell.budgetDifferenceView.layer.cornerRadius = cell.budgetDifferenceView.frame.height / 3
                let budgetDiff = projects[indexPath.row].balance - projectsShown[indexPath.row].budget
                
                let currencyFormatter = NumberFormatter()
                currencyFormatter.numberStyle = .currency
                
                if let localeIdentifier = Settings.shared.chosenLocaleIdentifier {
                    currencyFormatter.locale = Locale.init(identifier: localeIdentifier)
                } else {
                    currencyFormatter.locale = Locale.current
                    if Locale.current.currencyCode == "RUB" {
                        currencyFormatter.locale = Locale.init(identifier: "ru_RU")
                    }
                }
                
                if Settings.shared.recordCentsOn! {
                    currencyFormatter.minimumFractionDigits = 2
                    currencyFormatter.maximumFractionDigits = 2
                } else {
                    currencyFormatter.minimumFractionDigits = 0
                    currencyFormatter.maximumFractionDigits = 0
                }
                
                if budgetDiff > 0 {
                    cell.budgetDifferenceLabel.text = "+\(currencyFormatter.string(from: NSNumber(value: budgetDiff)) ?? "0")"
                    cell.budgetDifferenceLabel.textColor = UIColor(red: 0.45, green: 0.792, blue: 0.443, alpha: 1)
                } else if budgetDiff == 0 {
                    cell.budgetDifferenceLabel.text = "±\(currencyFormatter.string(from: NSNumber(value: budgetDiff)) ?? "0")"
                    cell.budgetDifferenceLabel.textColor = .tertiaryLabel
                } else {
                    cell.budgetDifferenceLabel.text = currencyFormatter.string(from: NSNumber(value: budgetDiff))
                    cell.budgetDifferenceLabel.textColor = UIColor(red: 0.898, green: 0.506, blue: 0.506, alpha: 1)
                }
            }
            
            let gradient: CAGradientLayer = CAGradientLayer()
            
            gradient.colors = [
                UIColor(red: 0.898, green: 0.506, blue: 0.506, alpha: 1).cgColor,
                UIColor(red: 0.792, green: 0.443, blue: 0.443, alpha: 1).cgColor
            ]
            gradient.cornerRadius = 10
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.5)
            gradient.frame = CGRect(x: 0.0,
                                    y: 0.0,
                                    width: cell.frame.size.width,
                                    height: cell.frame.size.height)

            cell.layer.insertSublayer(gradient, at: 0)
            
            cell.layer.cornerRadius = cell.frame.width / 10
            cell.name.text = projectsShown[indexPath.row].name
            cell.details.text = projectsShown[indexPath.row].details
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 178.0
        let height = 256.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == projectsShown.count {
            print("new project cell")
            delegate?.newProject()
        } else {
            delegate?.openProject(id: projects[indexPath.row].id)
        }
    }
}
