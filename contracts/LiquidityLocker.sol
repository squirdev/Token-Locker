// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.17;

// Dependency file: @openzeppelin/contracts/utils/Context.sol

// pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// Dependency file: @openzeppelin/contracts/access/Ownable.sol

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract LiquidityLocker is Ownable, ReentrancyGuard {
    uint256 public seconds_per_day = 24 * 60 * 60;

    uint256 public lockFee = 5 * 10 ** 16;

    struct LockerInfo {
        address tokenAddress; //locked token address
        uint256 tokenAmount; //locked token amount
        uint256 unlockTime;
    }

    struct UserInfo {
        mapping(uint256 => LockerInfo) lockers;
        uint256 noOfLockers;
        uint256 intialized;
    }

    mapping(address => UserInfo) public usersInfo;

    address[] public allUsers;

    event DepositComplete(
        address indexed user,
        address token,
        uint256 amount,
        uint256 time
    );
    event WithdrawComplete(
        address indexed user,
        address token,
        uint256 amount,
        uint256 time
    );

    constructor() {}

    function lockTokens(
        address lpTokenAddress,
        uint256 lpAmount,
        uint256 lockPeriodInDays
    ) external payable {
        UserInfo storage user = usersInfo[msg.sender];
        user.lockers[user.noOfLockers] = LockerInfo({
            tokenAddress: lpTokenAddress,
            tokenAmount: lpAmount,
            unlockTime: getToday(block.timestamp) +
                lockPeriodInDays *
                seconds_per_day
        });

        user.noOfLockers++;
        if (user.intialized == 0) {
            user.intialized = 1;
            allUsers.push(msg.sender);
        }

        IERC20 LockerToken = IERC20(lpTokenAddress);
        LockerToken.transferFrom(address(msg.sender), address(this), lpAmount);

        require(msg.value >= lockFee, "Insufficient Eth");

        emit DepositComplete(
            msg.sender,
            lpTokenAddress,
            lpAmount,
            block.timestamp
        );
    }

    function withdraw(uint256 lockerNumber) external nonReentrant {
        UserInfo storage user = usersInfo[msg.sender];
        LockerInfo storage locker = user.lockers[lockerNumber];
        require(
            block.timestamp >= locker.unlockTime,
            "Did not pass the lock period"
        );

        IERC20 LockerToken = IERC20(locker.tokenAddress);

        //replace withdrawing locker with last locker of this user
        //as a result, withdrawing locker is removed
        LockerInfo memory lastLocker = user.lockers[user.noOfLockers - 1];
        user.lockers[lockerNumber] = lastLocker;
        user.noOfLockers--;

        LockerToken.transfer(address(msg.sender), locker.tokenAmount);

        emit WithdrawComplete(
            msg.sender,
            locker.tokenAddress,
            locker.tokenAmount,
            block.timestamp
        );
    }

    function setLockFee(uint256 newLockFee) external onlyOwner {
        lockFee = newLockFee;
    }

    function transferOwnershipOfLocker(
        uint256 lockerNumber,
        address newOwner
    ) external {
        UserInfo storage oldUser = usersInfo[msg.sender];
        LockerInfo storage locker = oldUser.lockers[lockerNumber];

        //replace withdrawing locker with last locker of this user
        //as a result, withdrawing locker is removed
        LockerInfo memory lastLocker = oldUser.lockers[oldUser.noOfLockers - 1];
        oldUser.lockers[lockerNumber] = lastLocker;
        oldUser.noOfLockers--;

        UserInfo storage newUser = usersInfo[newOwner];
        newUser.lockers[newUser.noOfLockers] = locker;
        newUser.noOfLockers++;

        if (newUser.intialized == 0) {
            newUser.intialized = 1;
            allUsers.push(newOwner);
        }
    }

    function getToday(uint256 time) internal view returns (uint256) {
        return (time / seconds_per_day) * seconds_per_day;
    }
}
