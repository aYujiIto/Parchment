import Parchment
import UIKit

// First thing we need to do is create our own PagingItem that will
// hold our date. We need to make sure it conforms to Hashable and
// Comparable, as that is required by PagingViewController. We also
// cache the formatted date strings for performance.
struct CalendarItem: PagingItem, Hashable, Comparable {
    let date: Date
    let dateText: String
    let weekdayText: String

    init(date: Date) {
        self.date = date
        dateText = DateFormatters.dateFormatter.string(from: date)
        weekdayText = DateFormatters.weekdayFormatter.string(from: date)
    }

    static func < (lhs: CalendarItem, rhs: CalendarItem) -> Bool {
        return lhs.date < rhs.date
    }
}

class CalendarViewController: UIViewController {
    private let calendar: Calendar = .current
    private let pagingViewController = PagingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        pagingViewController.register(CalendarPagingCell.self, for: CalendarItem.self)
        pagingViewController.menuItemSize = .fixed(width: 48, height: 58)
        pagingViewController.textColor = UIColor.gray

        // Add the paging view controller as a child view
        // controller and constrain it to all edges
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)

        // Set our custom data source
        pagingViewController.infiniteDataSource = self

        // Set the current date as the selected paging item.
        let today = calendar.startOfDay(for: Date())
        pagingViewController.select(pagingItem: CalendarItem(date: today))

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Today",
            style: .plain,
            target: self,
            action: #selector(selectToday))
    }

    @objc private func selectToday() {
        let date = calendar.startOfDay(for: Date())
        pagingViewController.select(pagingItem: CalendarItem(date: date), animated: true)
    }
}

// We need to conform to PagingViewControllerDataSource in order to
// implement our custom data source. We set the initial item to be the
// current date, and every time pagingItemBeforePagingItem: or
// pagingItemAfterPagingItem: is called, we either subtract or append
// the time interval equal to one day. This means our paging view
// controller will show one menu item for each day.
extension CalendarViewController: PagingViewControllerInfiniteDataSource {
    func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem? {
        let calendarItem = pagingItem as! CalendarItem
        let nextDate = calendar.date(byAdding: .day, value: 1, to: calendarItem.date)!
        return CalendarItem(date: nextDate)
    }

    func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem? {
        let calendarItem = pagingItem as! CalendarItem
        let previousDate = calendar.date(byAdding: .day, value: -1, to: calendarItem.date)!
        return CalendarItem(date: previousDate)
    }

    func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
        let calendarItem = pagingItem as! CalendarItem
        let formattedDate = DateFormatters.shortDateFormatter.string(from: calendarItem.date)
        return ContentViewController(title: formattedDate)
    }

    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerBefore pagingItem: PagingItem) -> UIViewController? {
        guard let beforeItem = self.pagingViewController(pagingViewController, itemBefore: pagingItem, isGenerateLayout: true) else {
          return nil
        }
        return self.pagingViewController(pagingViewController, viewControllerFor: beforeItem)
    }

    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAfter pagingItem: PagingItem) -> UIViewController? {
        guard let afterItem = self.pagingViewController(pagingViewController, itemAfter:pagingItem, isGenerateLayout: true) else {
            return nil
        }
        return self.pagingViewController(pagingViewController, viewControllerFor: afterItem)
    }
}
