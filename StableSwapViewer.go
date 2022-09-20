// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package viewer

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
)

// IStableSwapPoolInfoViewerStableSwapPoolInfo is an auto generated low-level Go binding around an user-defined struct.
type IStableSwapPoolInfoViewerStableSwapPoolInfo struct {
	TotalSupply   *big.Int
	A             *big.Int
	Fees          [2]*big.Int
	TokenBalances []*big.Int
	Pool          common.Address
	LpToken       common.Address
	TokenList     []common.Address
	IsMeta        *big.Int
	Decimals      uint8
	Name          string
	Symbol        string
}

// StableSwapViewerMetaData contains all meta data concerning the StableSwapViewer contract.
var StableSwapViewerMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"address\",\"name\":\"pool\",\"type\":\"address\"}],\"name\":\"getPoolInfo\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"totalSupply\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"A\",\"type\":\"uint256\"},{\"internalType\":\"uint256[2]\",\"name\":\"fees\",\"type\":\"uint256[2]\"},{\"internalType\":\"uint256[]\",\"name\":\"tokenBalances\",\"type\":\"uint256[]\"},{\"internalType\":\"address\",\"name\":\"pool\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"lpToken\",\"type\":\"address\"},{\"internalType\":\"address[]\",\"name\":\"tokenList\",\"type\":\"address[]\"},{\"internalType\":\"uint256\",\"name\":\"isMeta\",\"type\":\"uint256\"},{\"internalType\":\"uint8\",\"name\":\"decimals\",\"type\":\"uint8\"},{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"}],\"internalType\":\"structIStableSwapPoolInfoViewer.StableSwapPoolInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]",
}

// StableSwapViewerABI is the input ABI used to generate the binding from.
// Deprecated: Use StableSwapViewerMetaData.ABI instead.
var StableSwapViewerABI = StableSwapViewerMetaData.ABI

// StableSwapViewer is an auto generated Go binding around an Ethereum contract.
type StableSwapViewer struct {
	StableSwapViewerCaller     // Read-only binding to the contract
	StableSwapViewerTransactor // Write-only binding to the contract
	StableSwapViewerFilterer   // Log filterer for contract events
}

// StableSwapViewerCaller is an auto generated read-only Go binding around an Ethereum contract.
type StableSwapViewerCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StableSwapViewerTransactor is an auto generated write-only Go binding around an Ethereum contract.
type StableSwapViewerTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StableSwapViewerFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type StableSwapViewerFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StableSwapViewerSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type StableSwapViewerSession struct {
	Contract     *StableSwapViewer // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// StableSwapViewerCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type StableSwapViewerCallerSession struct {
	Contract *StableSwapViewerCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts           // Call options to use throughout this session
}

// StableSwapViewerTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type StableSwapViewerTransactorSession struct {
	Contract     *StableSwapViewerTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts           // Transaction auth options to use throughout this session
}

// StableSwapViewerRaw is an auto generated low-level Go binding around an Ethereum contract.
type StableSwapViewerRaw struct {
	Contract *StableSwapViewer // Generic contract binding to access the raw methods on
}

// StableSwapViewerCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type StableSwapViewerCallerRaw struct {
	Contract *StableSwapViewerCaller // Generic read-only contract binding to access the raw methods on
}

// StableSwapViewerTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type StableSwapViewerTransactorRaw struct {
	Contract *StableSwapViewerTransactor // Generic write-only contract binding to access the raw methods on
}

// NewStableSwapViewer creates a new instance of StableSwapViewer, bound to a specific deployed contract.
func NewStableSwapViewer(address common.Address, backend bind.ContractBackend) (*StableSwapViewer, error) {
	contract, err := bindStableSwapViewer(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &StableSwapViewer{StableSwapViewerCaller: StableSwapViewerCaller{contract: contract}, StableSwapViewerTransactor: StableSwapViewerTransactor{contract: contract}, StableSwapViewerFilterer: StableSwapViewerFilterer{contract: contract}}, nil
}

// NewStableSwapViewerCaller creates a new read-only instance of StableSwapViewer, bound to a specific deployed contract.
func NewStableSwapViewerCaller(address common.Address, caller bind.ContractCaller) (*StableSwapViewerCaller, error) {
	contract, err := bindStableSwapViewer(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &StableSwapViewerCaller{contract: contract}, nil
}

// NewStableSwapViewerTransactor creates a new write-only instance of StableSwapViewer, bound to a specific deployed contract.
func NewStableSwapViewerTransactor(address common.Address, transactor bind.ContractTransactor) (*StableSwapViewerTransactor, error) {
	contract, err := bindStableSwapViewer(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &StableSwapViewerTransactor{contract: contract}, nil
}

// NewStableSwapViewerFilterer creates a new log filterer instance of StableSwapViewer, bound to a specific deployed contract.
func NewStableSwapViewerFilterer(address common.Address, filterer bind.ContractFilterer) (*StableSwapViewerFilterer, error) {
	contract, err := bindStableSwapViewer(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &StableSwapViewerFilterer{contract: contract}, nil
}

// bindStableSwapViewer binds a generic wrapper to an already deployed contract.
func bindStableSwapViewer(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(StableSwapViewerABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_StableSwapViewer *StableSwapViewerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _StableSwapViewer.Contract.StableSwapViewerCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_StableSwapViewer *StableSwapViewerRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StableSwapViewer.Contract.StableSwapViewerTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_StableSwapViewer *StableSwapViewerRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _StableSwapViewer.Contract.StableSwapViewerTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_StableSwapViewer *StableSwapViewerCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _StableSwapViewer.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_StableSwapViewer *StableSwapViewerTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _StableSwapViewer.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_StableSwapViewer *StableSwapViewerTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _StableSwapViewer.Contract.contract.Transact(opts, method, params...)
}

// GetPoolInfo is a free data retrieval call binding the contract method 0x06bfa938.
//
// Solidity: function getPoolInfo(address pool) view returns((uint256,uint256,uint256[2],uint256[],address,address,address[],uint256,uint8,string,string))
func (_StableSwapViewer *StableSwapViewerCaller) GetPoolInfo(opts *bind.CallOpts, pool common.Address) (IStableSwapPoolInfoViewerStableSwapPoolInfo, error) {
	var out []interface{}
	err := _StableSwapViewer.contract.Call(opts, &out, "getPoolInfo", pool)

	if err != nil {
		return *new(IStableSwapPoolInfoViewerStableSwapPoolInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(IStableSwapPoolInfoViewerStableSwapPoolInfo)).(*IStableSwapPoolInfoViewerStableSwapPoolInfo)

	return out0, err

}

// GetPoolInfo is a free data retrieval call binding the contract method 0x06bfa938.
//
// Solidity: function getPoolInfo(address pool) view returns((uint256,uint256,uint256[2],uint256[],address,address,address[],uint256,uint8,string,string))
func (_StableSwapViewer *StableSwapViewerSession) GetPoolInfo(pool common.Address) (IStableSwapPoolInfoViewerStableSwapPoolInfo, error) {
	return _StableSwapViewer.Contract.GetPoolInfo(&_StableSwapViewer.CallOpts, pool)
}

// GetPoolInfo is a free data retrieval call binding the contract method 0x06bfa938.
//
// Solidity: function getPoolInfo(address pool) view returns((uint256,uint256,uint256[2],uint256[],address,address,address[],uint256,uint8,string,string))
func (_StableSwapViewer *StableSwapViewerCallerSession) GetPoolInfo(pool common.Address) (IStableSwapPoolInfoViewerStableSwapPoolInfo, error) {
	return _StableSwapViewer.Contract.GetPoolInfo(&_StableSwapViewer.CallOpts, pool)
}
