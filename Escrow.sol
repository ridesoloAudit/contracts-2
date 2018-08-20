pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    mapping(address => bool) owners;

    event OwnerAdded(address indexed newOwner);
    event OwnerDeleted(address indexed owner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owners[msg.sender] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }


    function addOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        owners[_newOwner] = true;
        emit OwnerAdded(_newOwner);
    }

    function delOwner(address _owner) external onlyOwner {
        require(owners[_owner]);
        owners[_owner] = false;
        emit OwnerDeleted(_owner);
    }

    function isOwner(address _owner) public view returns (bool) {
        return owners[_owner];
    }
}






/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract Escrow is Ownable {
    using SafeMath for uint256;

    struct Stage {
        uint releaseTime;
        uint percent;
    }

    mapping (uint => Stage) public stages;
    uint public stageCount;

    uint public stopDay;
    uint public startBalance = 0;


    constructor(uint _stopDay) public {
        stopDay = _stopDay;
    }


    function addStage(uint _releaseTime, uint _percent) onlyOwner public {
        require(_releaseTime > stages[stageCount].releaseTime);
        stageCount++;
        stages[stageCount].releaseTime = _releaseTime;
        stages[stageCount].percent = _percent;
    }


    function getETH(uint _stage, address _to) onlyOwner external {
        require(stages[_stage].releaseTime < now);
        if (startBalance == 0) {
            startBalance = address(this).balance;
        }

        uint val = valueFromPercent(startBalance, stages[_stage].percent);
        _to.transfer(val);
    }


    function getAllETH(address _to) onlyOwner external {
        require(stopDay < now);
        require(address(this).balance > 0);
        _to.transfer(address(this).balance);
    }

    //1% - 100, 10% - 1000 50% - 5000
    function valueFromPercent(uint _value, uint _percent) internal pure returns (uint amount)    {
        uint _amount = _value.mul(_percent).div(10000);
        return (_amount);
    }
}



