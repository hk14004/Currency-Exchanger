//
//  CurrencyBalanceRepository.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Combine

protocol CurrencyBalanceRepository {
    func setBalance(_ balance: [CurrencyBalance]) async
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never>
    func getBalance() async -> [CurrencyBalance]
    func getBalance(forCurrency: Currency) async -> CurrencyBalance?
    func addOrUpdate(currencyBalance: [CurrencyBalance]) async
}
