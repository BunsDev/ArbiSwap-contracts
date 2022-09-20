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

// ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo is an auto generated low-level Go binding around an user-defined struct.
type ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo struct {
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

// CurveNoRegistryViewerMetaData contains all meta data concerning the CurveNoRegistryViewer contract.
var CurveNoRegistryViewerMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"address[]\",\"name\":\"_basePools\",\"type\":\"address[]\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"pool\",\"type\":\"address\"}],\"name\":\"getPoolInfo\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"totalSupply\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"A\",\"type\":\"uint256\"},{\"internalType\":\"uint256[2]\",\"name\":\"fees\",\"type\":\"uint256[2]\"},{\"internalType\":\"uint256[]\",\"name\":\"tokenBalances\",\"type\":\"uint256[]\"},{\"internalType\":\"address\",\"name\":\"pool\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"lpToken\",\"type\":\"address\"},{\"internalType\":\"address[]\",\"name\":\"tokenList\",\"type\":\"address[]\"},{\"internalType\":\"uint256\",\"name\":\"isMeta\",\"type\":\"uint256\"},{\"internalType\":\"uint8\",\"name\":\"decimals\",\"type\":\"uint8\"},{\"internalType\":\"string\",\"name\":\"name\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"symbol\",\"type\":\"string\"}],\"internalType\":\"structICurveNoRegistryPoolInfoViewer.CurveNoRegistryPoolInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]",
}

// CurveNoRegistryViewerABI is the input ABI used to generate the binding from.
// Deprecated: Use CurveNoRegistryViewerMetaData.ABI instead.
var CurveNoRegistryViewerABI = CurveNoRegistryViewerMetaData.ABI

// CurveNoRegistryViewer is an auto generated Go binding around an Ethereum contract.
type CurveNoRegistryViewer struct {
	CurveNoRegistryViewerCaller     // Read-only binding to the contract
	CurveNoRegistryViewerTransactor // Write-only binding to the contract
	CurveNoRegistryViewerFilterer   // Log filterer for contract events
}

// CurveNoRegistryViewerCaller is an auto generated read-only Go binding around an Ethereum contract.
type CurveNoRegistryViewerCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// CurveNoRegistryViewerTransactor is an auto generated write-only Go binding around an Ethereum contract.
type CurveNoRegistryViewerTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// CurveNoRegistryViewerFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type CurveNoRegistryViewerFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// CurveNoRegistryViewerSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type CurveNoRegistryViewerSession struct {
	Contract     *CurveNoRegistryViewer // Generic contract binding to set the session for
	CallOpts     bind.CallOpts          // Call options to use throughout this session
	TransactOpts bind.TransactOpts      // Transaction auth options to use throughout this session
}

// CurveNoRegistryViewerCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type CurveNoRegistryViewerCallerSession struct {
	Contract *CurveNoRegistryViewerCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts                // Call options to use throughout this session
}

// CurveNoRegistryViewerTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type CurveNoRegistryViewerTransactorSession struct {
	Contract     *CurveNoRegistryViewerTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts                // Transaction auth options to use throughout this session
}

// CurveNoRegistryViewerRaw is an auto generated low-level Go binding around an Ethereum contract.
type CurveNoRegistryViewerRaw struct {
	Contract *CurveNoRegistryViewer // Generic contract binding to access the raw methods on
}

// CurveNoRegistryViewerCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type CurveNoRegistryViewerCallerRaw struct {
	Contract *CurveNoRegistryViewerCaller // Generic read-only contract binding to access the raw methods on
}

// CurveNoRegistryViewerTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type CurveNoRegistryViewerTransactorRaw struct {
	Contract *CurveNoRegistryViewerTransactor // Generic write-only contract binding to access the raw methods on
}

// NewCurveNoRegistryViewer creates a new instance of CurveNoRegistryViewer, bound to a specific deployed contract.
func NewCurveNoRegistryViewer(address common.Address, backend bind.ContractBackend) (*CurveNoRegistryViewer, error) {
	contract, err := bindCurveNoRegistryViewer(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &CurveNoRegistryViewer{CurveNoRegistryViewerCaller: CurveNoRegistryViewerCaller{contract: contract}, CurveNoRegistryViewerTransactor: CurveNoRegistryViewerTransactor{contract: contract}, CurveNoRegistryViewerFilterer: CurveNoRegistryViewerFilterer{contract: contract}}, nil
}

// NewCurveNoRegistryViewerCaller creates a new read-only instance of CurveNoRegistryViewer, bound to a specific deployed contract.
func NewCurveNoRegistryViewerCaller(address common.Address, caller bind.ContractCaller) (*CurveNoRegistryViewerCaller, error) {
	contract, err := bindCurveNoRegistryViewer(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &CurveNoRegistryViewerCaller{contract: contract}, nil
}

// NewCurveNoRegistryViewerTransactor creates a new write-only instance of CurveNoRegistryViewer, bound to a specific deployed contract.
func NewCurveNoRegistryViewerTransactor(address common.Address, transactor bind.ContractTransactor) (*CurveNoRegistryViewerTransactor, error) {
	contract, err := bindCurveNoRegistryViewer(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &CurveNoRegistryViewerTransactor{contract: contract}, nil
}

// NewCurveNoRegistryViewerFilterer creates a new log filterer instance of CurveNoRegistryViewer, bound to a specific deployed contract.
func NewCurveNoRegistryViewerFilterer(address common.Address, filterer bind.ContractFilterer) (*CurveNoRegistryViewerFilterer, error) {
	contract, err := bindCurveNoRegistryViewer(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &CurveNoRegistryViewerFilterer{contract: contract}, nil
}

// bindCurveNoRegistryViewer binds a generic wrapper to an already deployed contract.
func bindCurveNoRegistryViewer(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(CurveNoRegistryViewerABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_CurveNoRegistryViewer *CurveNoRegistryViewerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _CurveNoRegistryViewer.Contract.CurveNoRegistryViewerCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_CurveNoRegistryViewer *CurveNoRegistryViewerRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _CurveNoRegistryViewer.Contract.CurveNoRegistryViewerTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_CurveNoRegistryViewer *CurveNoRegistryViewerRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _CurveNoRegistryViewer.Contract.CurveNoRegistryViewerTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_CurveNoRegistryViewer *CurveNoRegistryViewerCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _CurveNoRegistryViewer.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_CurveNoRegistryViewer *CurveNoRegistryViewerTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _CurveNoRegistryViewer.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_CurveNoRegistryViewer *CurveNoRegistryViewerTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _CurveNoRegistryViewer.Contract.contract.Transact(opts, method, params...)
}

// GetPoolInfo is a free data retrieval call binding the contract method 0x06bfa938.
//
// Solidity: function getPoolInfo(address pool) view returns((uint256,uint256,uint256[2],uint256[],address,address,address[],uint256,uint8,string,string))
func (_CurveNoRegistryViewer *CurveNoRegistryViewerCaller) GetPoolInfo(opts *bind.CallOpts, pool common.Address) (ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo, error) {
	var out []interface{}
	err := _CurveNoRegistryViewer.contract.Call(opts, &out, "getPoolInfo", pool)

	if err != nil {
		return *new(ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo)).(*ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo)

	return out0, err

}

// GetPoolInfo is a free data retrieval call binding the contract method 0x06bfa938.
//
// Solidity: function getPoolInfo(address pool) view returns((uint256,uint256,uint256[2],uint256[],address,address,address[],uint256,uint8,string,string))
func (_CurveNoRegistryViewer *CurveNoRegistryViewerSession) GetPoolInfo(pool common.Address) (ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo, error) {
	return _CurveNoRegistryViewer.Contract.GetPoolInfo(&_CurveNoRegistryViewer.CallOpts, pool)
}

// GetPoolInfo is a free data retrieval call binding the contract method 0x06bfa938.
//
// Solidity: function getPoolInfo(address pool) view returns((uint256,uint256,uint256[2],uint256[],address,address,address[],uint256,uint8,string,string))
func (_CurveNoRegistryViewer *CurveNoRegistryViewerCallerSession) GetPoolInfo(pool common.Address) (ICurveNoRegistryPoolInfoViewerCurveNoRegistryPoolInfo, error) {
	return _CurveNoRegistryViewer.Contract.GetPoolInfo(&_CurveNoRegistryViewer.CallOpts, pool)
}
