import Foundation

public protocol PagingMenuDataSource: AnyObject {
    func pagingItemBefore(pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem?
    func pagingItemAfter(pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem?
}
