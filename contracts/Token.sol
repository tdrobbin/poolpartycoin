pragma solidity ^0.6.0;

// SPDX-License-Identifier: MIT

import "./SafeMath.sol";

/**
    @title Bare-bones Token implementation
    @notice Based on the ERC-20 token standard as defined at
            https://eips.ethereum.org/EIPS/eip-20
 */
contract Token {

    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint256 public decimals;
    uint256 public totalSupply;
    uint256 public poolPartyLitLevel;
    address public admin;
    address[2] public initAddrs;
    uint8 public addrsClaimed;
    bool public claimingOn;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address from, address to, uint256 value);
    event Approval(address owner, address spender, uint256 value);
    event PoolPartyTurnedUp(address from, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint256 _totalSupply
    )
        public
    {
        // half goes to the addr creating the contract
        // and the other half gets split among the initAddrs
        address payable[2] memory initAddrsMem = [0xA868bC7c1AF08B8831795FAC946025557369F69C, 0x1CEE82EEd89Bd5Be5bf2507a92a755dcF1D8e8dc];
        // initAddrs = [0xA868bC7c1AF08B8831795FAC946025557369F69C, 0x1CEE82EEd89Bd5Be5bf2507a92a755dcF1D8e8dc];

        // make sure when we split coin among initAddrs we get integer amounts
        require(_totalSupply % (2 * initAddrs.length) == 0);

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        admin = msg.sender;

        balances[msg.sender] = _totalSupply.div(2);
        emit Transfer(address(0), msg.sender, _totalSupply.div(2));

        for(uint i = 0; i < 2; i ++) {
            // and the other half gets split among the initAddrs
            balances[initAddrs[i]] = _totalSupply.div(2).div(initAddrs.length);
        }

        poolPartyLitLevel = 100;

        addrsClaimed = 1;
        claimingOn = true;
    }

    /**
        @notice Getter to check the current balance of an address
        @param _owner Address to query the balance of
        @return Token balance
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
        @notice Getter to check the amount of tokens that an owner allowed to a spender
        @param _owner The address which owns the funds
        @param _spender The address which will spend the funds
        @return The amount of tokens still available for the spender
     */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
        @notice Approve an address to spend the specified amount of tokens on behalf of msg.sender
        @dev Beware that changing an allowance with this method brings the risk that someone may use both the old
             and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
             race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
             https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        @param _spender The address which will spend the funds.
        @param _value The amount of tokens to be spent.
        @return Success boolean
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /** shared logic for transfer and transferFrom */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balances[_from] >= _value, "Insufficient balance");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    /**
        @notice Transfer tokens to a specified address
        @param _to The address to transfer to
        @param _value The amount to be transferred
        @return Success boolean
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        @notice Transfer tokens from one address to another
        @param _from The address which you want to send tokens from
        @param _to The address which you want to transfer to
        @param _value The amount of tokens to be transferred
        @return Success boolean
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(allowed[_from][msg.sender] >= _value, "Insufficient allowance");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function turnUp(uint256 newLevel) public returns (bool) {
        require(balances[msg.sender] > 0);
        poolPartyLitLevel = newLevel;
        emit PoolPartyTurnedUp(msg.sender, newLevel);
        return true;

    }

    function mint(address _to, uint _value) public returns (bool) {
        require(msg.sender == admin);
        balances[_to] += _value;
        totalSupply += _value;
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function claim() public returns (bool) {
        require(claimingOn && balances[msg.sender] == 0);
        _transfer(address(0), msg.sender, 1);
        balances[msg.sender] += _value;
        totalSupply += _value;
        addrsClaimed += 1;
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function toggleClaiming() public returns (bool) {
        require(msg.sender == admin);
        claimingOn = !claimingOn;
        return (claimingOn);
    }

    // function claim() public void {
    //     bool senderIsInInitAddrs = False;
    //     for (uint i = 0; i < initAddrs.length; i++) {
    //         if (initAddrs[i] == msg.sender) {
    //             senderIsInInitAddrs = True;
    //             break;
    //         }
    //     }
    //     if (senderIsInInitAdds && !initAddrsClaimed[i]) {
    //         _transfer(address(0), 10000);
    //         initAddrsClaimed[i] = true;
    //     }
    // }

}
