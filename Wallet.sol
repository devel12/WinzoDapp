

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface UniswapRouter {
    function WETH() external pure returns (address);
    
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


contract Wallet {
    address UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    UniswapRouter uniswap = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
    

    
    mapping(address => uint) balances;
    mapping(address => uint) test;
    mapping(address => uint) depositTimestamps;

    
    function addBalance() public payable {
        balances[msg.sender] += msg.value;
        depositTimestamps[msg.sender] = block.timestamp;
    }
    
    function addBalanceERC20(address erc20TokenSmartContractAddress) public {
        IERC20 erc20 = IERC20(erc20TokenSmartContractAddress);
        
        // how many erc20tokens has the user (msg.sender) approved this contract to use?
        uint approvedAmountOfERC20Tokens = erc20.allowance(msg.sender, address(this));
        
        address token = erc20TokenSmartContractAddress;
        uint amountETHMin = 0; 
        address to = address(this);
        uint deadline = block.timestamp + (24 * 60 * 60);
    
        // transfer all those tokens that had been approved by user (msg.sender) to the smart contract (address(this))
        erc20.transferFrom(msg.sender, address(this), approvedAmountOfERC20Tokens);
        
        erc20.approve(UNISWAP_ROUTER_ADDRESS, approvedAmountOfERC20Tokens);
        
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        uniswap.swapExactTokensForETH(approvedAmountOfERC20Tokens, amountETHMin, path, to, deadline);

    }
    
    function getAllowanceERC20(address erc20TokenSmartContractAddress) public view returns(uint){
        IERC20 erc20 = IERC20(erc20TokenSmartContractAddress);
        return erc20.allowance(msg.sender, address(this));
    }
    
    function getBalance() public view returns(uint256) {
        return balances[msg.sender];
    }
    


    function withdraw(uint256 amount) public payable{
 
        require(balances[msg.sender] >= amount);
        address payable person = payable(msg.sender);

        person.transfer(amount);
        balances[msg.sender] -= amount;
    }
    
}
