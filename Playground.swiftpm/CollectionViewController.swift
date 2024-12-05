import UIKit

enum Section: Int {
  case items
}

struct Item: Hashable {
  let id: UUID = UUID()
}

final class CollectionViewController: UICollectionViewController {
  let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
  
  let cellRegistration = UICollectionView.CellRegistration(
    handler: { (cell: UICollectionViewListCell, indexPath, item: Item) in
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = "Hello, World!"
      cell.contentConfiguration = contentConfiguration
    }
  )
  
  lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(
    collectionView: collectionView,
    cellProvider: { [unowned self] (collectionView, indexPath, item) in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  )
  
  var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.setCollectionViewLayout(layout, animated: false)
    collectionView.dataSource = dataSource
    
    snapshot.appendSections([.items])
    snapshot.appendItems([Item(), Item(), Item()], toSection: .items)
    
    dataSource.apply(snapshot)
  }
}