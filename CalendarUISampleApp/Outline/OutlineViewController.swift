//
//  OutlineViewController.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit
import CalendarUI

class OutlineViewController: UIViewController {
    
    enum Section: String, CaseIterable {
        case monthly = "Monthly Calendars"
        case weekly = "Weekly Calendars"
        case transition = "Calendar Transitions"
        
        var title: String {
            self.rawValue
        }
        
        var data: [OutlineItem] {
            switch self {
            case .monthly:
                return [
                    OutlineItem(
                        title: "Multiple Selection",
                        viewController: MonthlyWithMultipleSelection.self,
                        subitems: []),
                ]
            case .weekly:
                return [
                    OutlineItem(
                        title: "Single Selection",
                        viewController: WeeklyWithSingleSelection.self,
                        subitems: [])
                ]
            case .transition:
                return [
                    OutlineItem(
                        title: "Week & Month",
                        viewController: WeekMonthTransitions.self,
                        subitems: [])
                ]
            }
        }
    }
    
    private var outlineCollection: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<
        Section, OutlineItem>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "CalendarUI"
        
        let layout = createLayout()
        outlineCollection = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: layout)
        outlineCollection.backgroundColor = .systemGroupedBackground
        outlineCollection.delegate = self
        view.addSubview(outlineCollection)
        
        configureDataSource()
        applySnapshots()
    }
}

// MARK: Layout and Data Source
private extension OutlineViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        var listConfiguration = UICollectionLayoutListConfiguration(
            appearance: .insetGrouped)
        listConfiguration.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(
            using: listConfiguration)
    }
    
    func configureDataSource() {
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] headerView, elementKind, indexPath in
            
            let headerItem = self.dataSource.snapshot()
                .sectionIdentifiers[indexPath.section]
            
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = headerItem.title
            
            headerView.contentConfiguration = configuration
        }
        
        let nodeItemRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell, OutlineItem> { cell, indexPath, item in
                var configuration = cell.defaultContentConfiguration()
                configuration.text = item.title
                configuration.textProperties
                    .font = .preferredFont(forTextStyle: .headline)
                cell.contentConfiguration = configuration
                
                let disclosureOption = UICellAccessory
                    .OutlineDisclosureOptions(style: .header)
                cell.accessories = [
                    .outlineDisclosure(options: disclosureOption)
                ]
            }
        
        let leafItemRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell, OutlineItem> { cell, indexPath, item in
                var configuration = cell.defaultContentConfiguration()
                configuration.text = item.title
                configuration.textProperties
                    .font = .preferredFont(forTextStyle: .subheadline)
                cell.contentConfiguration = configuration
                
                let disclosureOption = UICellAccessory.disclosureIndicator()
                cell.accessories = [ disclosureOption ]
            }
        
        dataSource = UICollectionViewDiffableDataSource<
            Section, OutlineItem>(collectionView: outlineCollection) { collectionView, indexPath, item in
                
                let configuration = item.subitems.isEmpty ?
                leafItemRegistration : nodeItemRegistration
                
                return collectionView.dequeueConfiguredReusableCell(
                    using: configuration, for: indexPath, item: item)
            }
        
        dataSource.supplementaryViewProvider = { [unowned self] collectionView, elementKind, indexPath in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return self.outlineCollection.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            } else {
                return nil
            }
        }
    }
}

// MARK: Snapshot
private extension OutlineViewController {
    
    func applySnapshots() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, OutlineItem>()
        snapshot.appendSections(Section.allCases)
        dataSource.apply(snapshot)

        for section in Section.allCases {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<OutlineItem>()
            for root in section.data {
                var frontier = [root]
                sectionSnapshot.append([root], to: nil)
                while !frontier.isEmpty {
                    let item = frontier.popLast()!
                    if !item.subitems.isEmpty {
                        sectionSnapshot.append(item.subitems, to: item)
                        frontier.append(contentsOf: item.subitems.reversed())
                    }
                }
            }
            dataSource.apply(sectionSnapshot, to: section)
        }
    }
}

// MARK: Delegate
extension OutlineViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        if let vc = item.targetController {
            navigationController?.pushViewController(vc.init(), animated: true)
        }
    }
}

