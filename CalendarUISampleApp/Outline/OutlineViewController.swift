//
//  OutlineViewController.swift
//  CalendarUISampleApp
//
//  Created by Michael Lin on 11/14/21.
//

import UIKit
import CalendarUI

class OutlineViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private let data: [OutlineItem] = [
        OutlineItem(title: "Monthly Calendars", subitems: [
            OutlineItem(title: "with Multiple Selection",
                        viewController: MonthViewController.self,
                        subitems: []),
        ]),
        OutlineItem(title: "Weekly Calendars", subitems: [
            OutlineItem(title: "with Multiple Selection",
                        viewController: WeekViewController.self,
                        subitems: []),
        ]),
    ]
    
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
        let snapshot = generateSnapshot()
        dataSource.apply(snapshot, to: .main)
    }
}

// MARK: Layout and Data Source
private extension OutlineViewController {
    
    func createLayout() -> UICollectionViewLayout {
        
        let listConfiguration = UICollectionLayoutListConfiguration(
            appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(
            using: listConfiguration)
    }
    
    func configureDataSource() {
        
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
    }
}

// MARK: Snapshot
private extension OutlineViewController {
    
    func generateSnapshot() -> NSDiffableDataSourceSectionSnapshot<OutlineItem> {
        
        var snapshot = NSDiffableDataSourceSectionSnapshot<OutlineItem>()

        for root in data {
            var frontier = [root]
            snapshot.append([root], to: nil)
            while !frontier.isEmpty {
                let item = frontier.popLast()!
                if !item.subitems.isEmpty {
                    snapshot.append(item.subitems, to: item)
                    frontier.append(contentsOf: item.subitems.reversed())
                }
            }
        }
        
//        snapshot.append([parent], to: nil)
//        snapshot.append(parent.subitems, to: parent)
        return snapshot
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

