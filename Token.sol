// SPDX-License-Identifier: UNLICENSED

// t.me/TM_Base (https://t.me/TM_Base)

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Import Uniswap Interface
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
* Dogira.net - TimeLock
* @dev Implementation of a simple timelock mechanism for protecting high-security functions.
*
* The modifier withTimelock(functionName) can be added to any function, ensuring any use
* is preceeded by a 24hr wait period, and an appropriate event emission. Following execution
* of the function, the lock will be automatically re-applied.
*/
abstract contract TimeLock is Ownable {
    uint256 public constant lockDuration = 24 hours;

    mapping(bytes32 => uint256) public unlockTimestamps;

    event FunctionUnlocked(bytes32 indexed functionIdentifier, uint256 unlockTimestamp);

    modifier withTimelock(string memory functionName) {
        bytes32 functionIdentifier = keccak256(bytes(functionName));
        require(unlockTimestamps[functionIdentifier] != 0, "Function is locked");
        require(block.timestamp >= unlockTimestamps[functionIdentifier], "Timelock is active");
        _;
        lockFunction(functionName);
    }

    function unlockFunction(string memory functionName) public onlyOwner {
        bytes32 functionIdentifier = keccak256(bytes(functionName));
        uint256 unlockTimestamp = block.timestamp + lockDuration;
        unlockTimestamps[functionIdentifier] = unlockTimestamp;
        emit FunctionUnlocked(functionIdentifier, unlockTimestamp);
    }

    function lockFunction(string memory functionName) internal {
        bytes32 functionIdentifier = keccak256(bytes(functionName));
        unlockTimestamps[functionIdentifier] = 0;
    }
}

/*
* @title BotFather Token .
* @author a cool developer
* @notice This contract is a simple Token with tax and liquidity filling functions. Some Security features are also added
* @dev -
*/
contract Token is ERC20, Ownable, TimeLock {
    
    using SafeMath for uint256;
    using Address for address;

    // defaults
    string private _name    = "BotFather";
    string private _symbol  = "BTFTR";
    uint8 private _decimals = 18;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _totalSupply = 100_000_000_000 ether;

    // misc
    mapping (address => mapping (address => uint256)) private _allowances;
    address[] private _nonCirculatingAddresses;

    // Taxing
    mapping (address => bool) private _isExcludedFromTax;   //Always exempt from tax (overrides _isTaxed), for owner adding initial LP etc
    mapping (address => bool) private _isTaxed;             //Any LPs intended to be taxed

    address public marketingWallet;
    uint256 public taxForLiquidity = 1;
    uint256 public taxForMarketing = 2;

    uint256 public numTokensSellToAddToLiquidity = 10_000 ether; // 10000 * 10**_decimals;
    uint256 public numTokensSellToAddToNativeToken = 5_000 ether; // 5000 * 10**_decimals;
    uint256 private _marketingReserves = 0;

    // swap variables
    bool initialPairSet = false;
    bool inSwapAndLiquify;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    // events
    event MarketingWalletChanged(address indexed previousWallet, address indexed newWallet);
    event PrimaryPairUpdated(address indexed previousPair, address indexed newPair);
    event PrimaryRouterUpdated(address indexed previousRouter, address indexed newRouter);
    event PrimaryPairAutoDetected(address indexed previousPair, address indexed newPair);
    event TaxStatusUpdated(address indexed account, bool isTaxed);
    event ExemptStatusUpdated(address indexed account, bool isExempt);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event TaxRatesChanged(
        uint256 previousTaxForLiquidity, 
        uint256 previousTaxForMarketing, 
        uint256 newTaxForLiquidity, 
        uint256 newTaxForMarketing
    );

    event SwapThresholdsChanged(
        uint256 previousNumTokensSellToAddToLiquidity, 
        uint256 previousNumTokensSellToAddToNativeToken, 
        uint256 newNumTokensSellToAddToLiquidity, 
        uint256 newNumTokensSellToAddToNativeToken
    );

    // modifiers
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address _marketing, address _primaryRouter ) ERC20(_name, _symbol) Ownable(_msgSender()) 
    {
        _mint(msg.sender, _totalSupply);

        marketingWallet = _marketing;

        changeMarketingWallet(_marketing);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_primaryRouter);

        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromTax[owner()] = true;
        _isExcludedFromTax[address(this)] = true;
        _isExcludedFromTax[_marketing] = true;
    }

    /**
     * @dev Bypasses the TimeLock to set the pair for the first time.
     * 
     * Implemented due to a strange problem on quickswap v2 on Dogechain.
     * Creating the pair in the constructor without supplying LP seems to
     * cause the uniswapfactory to record a non-contract addr as the pair.
     *
     * This allows allows for a user to manually deploy & supply their pair,
     * then provide the pair addr to the contract.
     *
     * Cannot be called more than once - timelock function must be used
     * for updating the pair addr in future.
     */
    function setInitialPair(address _pair) external onlyOwner {
        require(!initialPairSet, "Initial Pair has already been set!");
        require(_pair != address(0), "Pair address cannot be the zero address");
        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        address token0 = pair.token0();
        address token1 = pair.token1();
        address weth = uniswapV2Router.WETH();

        require(
            (token0 == address(this) && token1 == weth) || (token0 == weth && token1 == address(this)),
            "Pair must contain the token and WETH"
        );

        uniswapV2Pair = _pair;
        initialPairSet = true;
        emit PrimaryPairUpdated(address(0), uniswapV2Pair);
    }

    /*
    * @notice transfers the tokens between wallets.
    * @dev  The _transfer function manages the internal transfer of tokens between two addresses. It:
    *       Validates basic transfer conditions.
    *       Calculates & Deducts taxes for marketing and liquidity if applicable.
    *       Adds liquidity and funds the marketing wallet if certain thresholds are reached.
    *       Completes the transfer of the remaining tokens after all deductions.
    *       In essence, it oversees transfers while handling taxation, liquidity provision, and marketing contributions.
    * @param from address , to address, amount of tokens
    * @return none
    */
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance");

        uint256 transferAmount = amount;

        // if not excluded from tax
        if (!_isExcludedFromTax[from] && !_isExcludedFromTax[to]) {
            // if included in taxed, take tax from sent amount
            if (_isTaxed[from] || _isTaxed[to]) {
                uint256 marketingShare = amount.mul(taxForMarketing).div(100);
                uint256 liquidityShare = amount.mul(taxForLiquidity).div(100);
                // subtract taxes from amount
                transferAmount = amount.sub(marketingShare.add(liquidityShare));

                // add marketingShare to the _marketingReserves
                _marketingReserves = _marketingReserves.add(marketingShare);

                // transfer whole tax to contract
                super._transfer(from, address(this), marketingShare.add(liquidityShare));
            }

            // if target is uniswappair and actually not in the swap procedure, enter swap routines
            if (to == uniswapV2Pair && !inSwapAndLiquify) {
                uint256 contractLiquidityBalance = balanceOf(address(this)).sub(_marketingReserves);

                // if contractLiquidityBalance exceeds the threshold call swap and liquify
                if (contractLiquidityBalance >= numTokensSellToAddToLiquidity) {
                    _swapAndLiquify(numTokensSellToAddToLiquidity);
                }

                // if _marketingReserves exceeds the threshold call swap for native tokens
                if (_marketingReserves >= numTokensSellToAddToNativeToken) {
                    _swapTokensForEth(numTokensSellToAddToNativeToken);
                    _marketingReserves = _marketingReserves.sub(numTokensSellToAddToNativeToken);
                    // send holding eth to marketingWallet
                    bool sent = payable(marketingWallet).send(address(this).balance);
                    require(sent, "Failed to send native token");
                }
            }
        }    
        // transfer rest amount exclusive the taxes
        super._transfer(from, to, transferAmount);
    }

    /*
    * @notice Swap and Liquify. The consequence of this function is that it helps to stabilize the price of the token. 
    * It increases the liquidity of the Uniswap pool, which means that it is less likely for the price of the token to fluctuate greatly when large quantities are bought or sold.
    * @dev cuts the contract token balance in half and swaps and liquifies it.
    * @param contractTokenBalance contract balance
    * @return none
    */
    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap 
    {
        uint256 half = (contractTokenBalance / 2);
        uint256 otherHalf = (contractTokenBalance - half);

        // initial eth balance
        uint256 initialBalance = address(this).balance;

        _swapTokensForEth(half);

        // new eth balance
        uint256 newBalance = (address(this).balance - initialBalance);

        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    /*
    * @notice Swap Tokens for Native Token.
    * @dev The _swapTokensForEth function exchanges a specified amount of the contract's tokens for ETH using Uniswap, with the received ETH stored in the contract's address.
    * @param tokenAmount amount of tokens
    * @return none
    */
    function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap 
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            (block.timestamp + 300)
        );
    }

    /*
    * @notice Add Liquidity.
    * @dev The _addLiquidity function uses a given amount of the contract's tokens and ETH to add liquidity to a Uniswap pool, with the liquidity tokens sent to the contract's owner.
    * @param tokenAmount amount of tokens, ethAmount amount of eth
    * @return none
    */
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private lockTheSwap
    {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    /*
    * @notice Transfer To Address ETH
    * @dev 
    * @param recipient gets eth, amount of eth
    * @return none
    */
    //function transferToAddressETH(address payable recipient, uint256 amount) private {
    //    recipient.transfer(amount);
    //}
    
    /*
    * @notice to recieve ETH from uniswapV2Router when swaping
    * @dev -
    * @param -
    * @return none
    */
    //receive() external payable {}

    /*
    * @notice airdrop function, allows to send tokens on multiple wallets.
    * @dev The airdrop function allows the contract's owner to distribute specified amounts of tokens to a list of addresses in a single transaction.
    * @param accounts addresses-array , amounts amounts-array
    * @return none
    */
    function airdrop(address[] memory accounts, uint256[] memory amounts)
        external
        onlyOwner
    {
        require(
            accounts.length == amounts.length,
            "arrays must be the same length"
        );
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint256 amount = amounts[i];
            _transfer(_msgSender(), account, amount);
        }
    }

    /*
    * @notice Change Marketing Wallet.
    * @dev The changeMarketingWallet function allows the contract's owner to set a new address for the marketing wallet, ensuring it's neither the zero nor the dead address. An event is emitted upon change.
    * @param newWallet address of the new wallet
    * @return success boolean 
    */
    function changeMarketingWallet(address newWallet) public onlyOwner returns(bool)
    {
        require(newWallet != address(0), "New marketing wallet cannot be the zero address");
        require(newWallet != deadAddress, "New marketing wallet cannot be the dead address");
        marketingWallet = newWallet;
        emit MarketingWalletChanged(marketingWallet, newWallet);
        return true;
    }

    /*
    * @notice Change swap thresholds
    * @dev The changeSwapThresholds function lets the contract owner modify the thresholds for liquidity addition and native token acquisition, with both thresholds capped at 1% of the total token supply. It then emits an event detailing the change.
    * @param _numTokensSellToAddToLiquidity liquidity threshold, _numTokensSellToAddTNativeToken nativeToken threshold
    * @return success boolean 
    */
    function changeSwapThresholds(uint256 _numTokensSellToAddToLiquidity, uint256 _numTokensSellToAddTNativeToken) external onlyOwner returns (bool)
    {
        require(_numTokensSellToAddToLiquidity <= _totalSupply / 100, "Cannot liquidate more than 1% of the supply at once!");
        require(_numTokensSellToAddTNativeToken <= _totalSupply / 100, "Cannot liquidate more than 1% of the supply at once!");

        uint256 tempNumTokensSellToAddToLiquidity = numTokensSellToAddToLiquidity;
        uint256 tempNumTokensSellToAddToNativeToken = numTokensSellToAddToLiquidity;

        numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity * 10**_decimals;
        numTokensSellToAddToNativeToken = _numTokensSellToAddTNativeToken * 10**_decimals;

        emit SwapThresholdsChanged(tempNumTokensSellToAddToLiquidity, tempNumTokensSellToAddToNativeToken, numTokensSellToAddToLiquidity, numTokensSellToAddToNativeToken);
        return true;
    }

    /*
    * @notice Change Tax for Liquidity and Marketing.
    * @dev The changeTaxForLiquidityAndMarketing function allows the contract owner to adjust the tax rates for liquidity and marketing. The combined tax rate is capped at 9%. An event is emitted after changing the rates, and the function has a timelock for added security.
    * @param _taxForLiquidity liquidity tax, _taxForMarketing marketing tax
    * @return success boolean 
    */
    function changeTaxForLiquidityAndMarketing(uint256 _taxForLiquidity, uint256 _taxForMarketing) external withTimelock("changeTaxForLiquidityAndMarketing") onlyOwner returns (bool)
    {
        require((_taxForLiquidity+_taxForMarketing) <= 9, "Total tax must not be greater than 9%");

        uint256 tempTaxForLiquidity = taxForLiquidity;
        uint256 tempTaxForMarketing = taxForMarketing;

        taxForLiquidity = _taxForLiquidity;
        taxForMarketing = _taxForMarketing;

        emit TaxRatesChanged(tempTaxForLiquidity, tempTaxForMarketing, _taxForLiquidity, _taxForMarketing);
        return true;
    }

    /*
    * @notice Update PrimaryPair for swap-platforms.
    * @dev The updatePrimaryPair function lets the contract owner change the primary Uniswap pair. It has a timelock for safety. The new pair must involve the contract's native token and WETH. An event logs the change.
    * @param _pair address of the uniswap-pair-contract
    * @return none
    */
    function updatePrimaryPair(address _pair) external withTimelock("updatePrimaryPair") onlyOwner {
        require(_pair != address(0), "Pair address cannot be the zero address");
        require(_pair != deadAddress, "Pair address cannot be the dead address");

        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        address token0 = pair.token0();
        address token1 = pair.token1();
        address weth = uniswapV2Router.WETH();

        require(
            (token0 == address(this) && token1 == weth) || (token0 == weth && token1 == address(this)),
            "Pair must contain the native token and WETH"
        );

        address oldPair = uniswapV2Pair;
        uniswapV2Pair = _pair;
        emit PrimaryPairUpdated(oldPair, uniswapV2Pair);
    }

    /*
    * @notice Update PrimaryRouter for swap-platforms.
    * @dev The updatePrimaryRouter function allows the contract owner, with a safety timelock, to update the primary Uniswap router. It checks for valid addresses and logs the change through an event.
    * @param _router address of the uniswap router
    * @return none
    */
    function updatePrimaryRouter(address _router) external withTimelock("updatePrimaryRouter") onlyOwner {
        require(_router != address(0), "Router address cannot be the zero address");
        require(_router != deadAddress, "Pair address cannot be the dead address");

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        address factoryAddress = _uniswapV2Router.factory();
        require(factoryAddress != address(0), "Router must have a valid factory address");
        require(factoryAddress != deadAddress, "Router must have a valid factory address");

        address oldRouter = address(uniswapV2Router);
        uniswapV2Router = _uniswapV2Router;
        emit PrimaryRouterUpdated(oldRouter, address(uniswapV2Router));
    }

    /*
    * @notice Set tax target address
    * @dev Sets the marketingWallet address where tax funds are directed and emits an event indicating the update.
    * @param account address
    * @return none
    */
    function setTaxTarget(address account) public onlyOwner {
        marketingWallet = account;
        emit TaxStatusUpdated(account, false);
    }

    /*
    * @notice Add address to _isTaxed
    * @dev Includes an account to a list that will be taxed on transfers, and logs this addition with an event.
    * @param account address
    * @return none
    */
    function addToTaxed(address account) external onlyOwner {
        _isTaxed[account] = true;
        emit TaxStatusUpdated(account, true);
    }

    /*
    * @notice Remove address from _isTaxed
    * @dev Excludes an account from being taxed on transfers, and logs this removal with an event.
    * @param account address
    * @return none
    */
    function removeFromTaxed(address account) external onlyOwner {
        _isTaxed[account] = false;
        emit TaxStatusUpdated(account, false);
    }

    /*
    * @notice Add address to _isExcludedFromTax 
    * @dev Exempts an account from any tax, and logs this addition.
    * @param account address
    * @return none
    */
    function addToExempt(address account) external onlyOwner {
        _isExcludedFromTax[account] = true;
        emit ExemptStatusUpdated(account, true);
    }

    /*
    * @notice Remove address from_isExcludedFromTax
    * @dev Removes the tax exemption of an account (but mistakenly sets the exemption flag to true) and logs the removal (indicating false).
    * @param account address
    * @return none
    */
    function removeFromExempt(address account) external onlyOwner {
        _isExcludedFromTax[account] = true;
        emit ExemptStatusUpdated(account, false);
    }

    /*
    * @notice Add address to _nonCirculatingAddresses
    * @dev Adds an address to the non-circulating list. Callable by owner only.
    * @param account address
    * @return none
    */
    function AddNonCirculatingAddress(address account) external onlyOwner {
        _nonCirculatingAddresses.push(account);
    }

    /*
    * @notice remove address from _nonCirculatingAddresses
    * @dev Removes an address from the non-circulating list using the given address. Swaps the target with the last item, then pops it. Callable by owner only.
    * @param account address
    * @return none
    */
    function RemoveNonCirculatingAddress(address account) external onlyOwner {
        uint256 index = findAddress(account);
        require(index < _nonCirculatingAddresses.length, "Address not found");

        // Ersetzen Sie das zu entfernende Element durch das letzte Element
        _nonCirculatingAddresses[index] = _nonCirculatingAddresses[_nonCirculatingAddresses.length - 1];
        
        // Größe des Arrays verringern
        _nonCirculatingAddresses.pop();
    }

    /*
    * @notice find address in _nonCirculatingAddresses
    * @dev Returns the index of a given address in the non-circulating list; returns array length if not found.
    * @param account address
    * @return index of address
    */
    function findAddress(address account) internal view returns(uint256) {
        for(uint256 i = 0; i < _nonCirculatingAddresses.length; i++) {
            if(_nonCirculatingAddresses[i] == account) {
                return i;
            }
        }
        return _nonCirculatingAddresses.length;
    }

    /*
    * @notice Get circulating supply
    * @dev Calculates the circulating supply by deducting the total balances of non-circulating addresses from the total supply. Accessible only to the owner.
    * @param none
    * @return circulating supply
    */
    function getCirculatingSupply() public view onlyOwner returns (uint256) {
        uint256 nonCirculating = 0;
        for (uint256 i = 0; i < _nonCirculatingAddresses.length; i++) {
            nonCirculating += balanceOf(_nonCirculatingAddresses[i]);
        }
        return _totalSupply.sub(nonCirculating);
    }
}
