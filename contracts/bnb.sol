// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.2;

/**
   * 1) Contract owner can deposit BNB into smart contract

* 2) Contract owner can withdraw BNB from contract

* 3) The contract owner can request the contract to Stake a set amount of BnB in the contract with the venus protocol

* 4) The contract owner user can request the contract to unstake a set amount of BNB from venus protocol

* 5) The contract owner can use pancake swap to swap BNB in the contract to BUSD that is kept in the contract

* 6) The contract owner can use pancake swap to swap BUSD in the contract to BNB that is kept in the contract

* 7) The contract needs to track BNB currently in Contract, BUSD currently in contract, and amount BNB staked with venus protocol
   */
   
import "./dependencies/IPancakeRouter02.sol";
import "./SafeMath.sol";
import "./dependencies/VBNB.sol";


contract BUSDbasic{
    using SafeMath for uint256;
    mapping(address => uint256) internal balances;
    string public constant name = "Binance USD"; // solium-disable-line
    string public constant symbol = "BUSD"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase
     mapping(address => bool) internal frozen;
     mapping(address => mapping(address => uint256)) internal allowed;
     bool private initialized = false;
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {
        require(_to != address(0), "cannot transfer to address zero");
        require(!frozen[_to] && !frozen[_from] && !frozen[msg.sender], "address frozen");
        require(_value <= balances[_from], "insufficient funds");
        require(_value <= allowed[_from][msg.sender], "insufficient allowance");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "cannot transfer to address zero");
        require(!frozen[_to] && !frozen[msg.sender], "address frozen");
        require(_value <= balances[msg.sender], "insufficient funds");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(!frozen[_spender] && !frozen[msg.sender], "address frozen");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 contract BNBTransfer{
       
       VBNB public vbnb;
       uint256 BNBbalance;
       uint256 VTokenbalance;
       BUSDbasic public BUSD;
       address internal constant PANCAKESWAP_ROUTER_ADDRESS = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
       IPancakeRouter02 public pancakeswapRouter;
       
       address private BUSDaddress = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
       
       
       constructor() public  {
           pancakeswapRouter = IPancakeRouter02(PANCAKESWAP_ROUTER_ADDRESS);
       }
       function depositBNB() public payable {
           BNBbalance += msg.value;
       }
       
       function getBalance() public view returns(uint){
           return address(this).balance;
       }
       
       function withdrawBNB() public {
           msg.sender.transfer(address(this).balance);
       }
       
    function stakeBNB() public payable {
        vbnb.mint();
    }
    
    function unstakeBNB() public payable {
        vbnb.redeem(VTokenbalance);
    }
    
    function BNBBalance() public{
        VTokenbalance = vbnb.balanceOfUnderlying(address(this))/vbnb.exchangeRateCurrent();
    }
    function convertBNBToBUSD(uint BUSDAmount) public payable {
           uint deadline = now + 120;
           pancakeswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(BUSDAmount, getPathForETHtoBUSD(), address(this), deadline);
           // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
       }
       
       function convertBUSDToBNB(uint256 BNBAmount) public payable{
           require(BUSD.transferFrom(msg.sender, address(this), BNBAmount), 'transferFrom failed.');
           require(BUSD.approve(address(pancakeswapRouter), BNBAmount), 'approve failed.');
           uint deadline = now + 120;
           address[] memory path = new address[](2);
           path[0] = address(BUSD);
           path[1] = pancakeswapRouter.WETH();
           pancakeswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(BNBAmount, pancakeswapRouter.getAmountIn( BNBAmount, path[0].balance, path[1].balance), path, address(this), deadline);
       }
       function getEstimatedETHforBUSD(uint BUSDAmount) public view returns (uint[] memory) {
            return pancakeswapRouter.getAmountsIn(BUSDAmount, getPathForETHtoBUSD());
  }
  
    function getPathForETHtoBUSD() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = pancakeswapRouter.WETH();
        path[1] = BUSDaddress;
    
        return path;
  }
  
  // important to receive ETH
  receive() payable external {}
      
  // important to receive ETH
 

      
   }