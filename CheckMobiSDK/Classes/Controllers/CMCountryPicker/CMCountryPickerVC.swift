//
//  CMCountryPickerVC.swift
//  Alamofire
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import UIKit
import Moya

protocol CMCountryPickerVCProtocol: class {
    func countryPickerVCDidSelect(country: Country)
}

class CMCountryPickerVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    private var dataSource = [Country]()
    var filteredCountries = [Country]()
    weak var delegate: CMCountryPickerVCProtocol?
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchController()
        self.getDataSource()
    }
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            self.searchController.obscuresBackgroundDuringPresentation = false
        }
        self.searchController.searchBar.placeholder = "Search"
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
        self.definesPresentationContext = true
    }
    
    private func getDataSource() {
        self.displayActivityIndicator(shouldDisplay: true)
        APIProvider.request(.getCountries) { [weak self] result in
            self?.displayActivityIndicator(shouldDisplay: false)
            if let response = try? result.get(),
                let countries = try? response.mapArray(Country.self) {
                self?.dataSource = countries
                self?.tableView.reloadData()
            }
        }
    }
    
    func isFiltering() -> Bool {
        return self.searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        self.filteredCountries = self.dataSource.filter({( country: Country) -> Bool in
            return (country.name?.lowercased().range(of: searchText.lowercased()) != nil ||
                    country.prefix?.lowercased().range(of: searchText.lowercased()) != nil)
        })
        self.tableView.reloadData()
    }

    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}

extension CMCountryPickerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.filteredCountries.count
        }
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "CMCountryCell",
                                                  for: indexPath) as! CMCountryCell
        cell.setupWith(country: self.isFiltering() ?
            self.filteredCountries[indexPath.row] : self.dataSource[indexPath.row])
        return cell
    }
}

extension CMCountryPickerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = self.isFiltering() ?
            self.filteredCountries[indexPath.row] : self.dataSource[indexPath.row]
        if self.isFiltering() {
            self.searchController.isActive = false
        }
        self.delegate?.countryPickerVCDidSelect(country: country)
        self.dismiss(animated: true)
    }
}

extension CMCountryPickerVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
}


