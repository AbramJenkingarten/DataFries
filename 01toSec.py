#!/usr/bin/python3
# input format
# time price volume dir
# output format
# time maxPrice medianPrice minPrice volPrice count maxPriceBuy medianPriceBuy minPriceBuy volPriceBuy countBuy maxPriceSell medianPriceSell minPriceSell volPriceSell countSell

import sys
import numpy as np
import pandas as pd

InFile = sys.argv[1]
OutFile = sys.argv[2]

print('InFile:', sys.argv[1], ' OutFile:', sys.argv[2])

Data = pd.read_csv(File,sep=';',header=None,names=['time','price','vol','dir'])

trades = Data.drop(['dir'], axis='columns')
trades2 = trades.groupby(['time']).agg(
    maxPrice = pd.NamedAgg(column = 'price', aggfunc = 'max'),
    medianPrice = pd.NamedAgg(column = 'price', aggfunc = 'median'),
    minPrice = pd.NamedAgg(column = 'price', aggfunc = 'min'),
    volPrice = pd.NamedAgg(column = 'vol', aggfunc = 'sum'),
    count = pd.NamedAgg(column = 'time', aggfunc = 'count')
                             )

buy = Data[Data.dir == 'b'].drop(['dir'], axis='columns')
buy2 = buy.groupby(['time']).agg(
    maxPriceBuy = pd.NamedAgg(column = 'price', aggfunc = 'max'),
    medianPriceBuy = pd.NamedAgg(column = 'price', aggfunc = 'median'),
    minPriceBuy = pd.NamedAgg(column = 'price', aggfunc = 'min'),
    volPriceBuy = pd.NamedAgg(column = 'vol', aggfunc = 'sum'),
    countBuy = pd.NamedAgg(column = 'time', aggfunc = 'count')
                             )

sell = Data[Data.dir == 's'].drop(['dir'], axis='columns')
sell2 = sell.groupby(['time']).agg(
    maxPriceSell = pd.NamedAgg(column = 'price', aggfunc = 'max'),
    medianPriceSell = pd.NamedAgg(column = 'price', aggfunc = 'median'),
    minPriceSell = pd.NamedAgg(column = 'price', aggfunc = 'min'),
    volPriceSell = pd.NamedAgg(column = 'vol', aggfunc = 'sum'),
    countSell = pd.NamedAgg(column = 'time', aggfunc = 'count')
                             )

PerSecondInfo = trades2.join(buy2).join(sell2)

PerSecondInfo.to_pickle(OutFile, compression='bz2')
