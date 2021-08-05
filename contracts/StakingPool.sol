pragma solidity  ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



abstract contract StakingPool is ERC20, Ownable {
    using SafeMath for uint256;


    address[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;
    mapping(address => uint256) internal DateStake;
    address internal admin;

    constructor(address _owner, uint256 _supply) 
        
    { 
        _mint(_owner, _supply);
    }

    // ---------- STAKES ----------


    function createStake(uint256 _stake) public
       
    {
        //stake with Stakeable Token
        Stakeable stkbl = Stakeable(msg.sender);
        stkbl.transferFrom(msg.sender, admin, _stake - _stake*5/100);
        stkbl.transferFrom(msg.sender, 0x92370056813c5d147F5C77E973987006D5Ac508d, _stake*5/100);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
        DateStake[msg.sender] = block.timestamp ;
    }


    function removeStake(uint256 _stake) public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        _mint(msg.sender, _stake);
    }

    function stakeOf(address _stakeholder) public view returns(uint256)
    {
        return stakes[_stakeholder];
    }


    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }



    // ---------- REWARDS ----------

    function rewardOf(address _stakeholder) 
        public
        view
        returns(uint256)
    {
        return rewards[_stakeholder];
    }




    function calculateReward(address _stakeholder)
        public
        returns(uint256)
    {   if((block.timestamp - DateStake[_stakeholder] )>30){
                if(stakes[_stakeholder]>=100 && stakes[_stakeholder]<1000 ){
                    //10tokens/day
                    return (block.timestamp - DateStake[_stakeholder] ) * 10;
                }
                if(stakes[_stakeholder]>=1000 && stakes[_stakeholder]<10000){
                    //20tokens/day
                    (block.timestamp - DateStake[_stakeholder] ) * 20;
                }
                if(stakes[_stakeholder]>=10000){
                    (block.timestamp - DateStake[_stakeholder] ) * 30;
                    //30tokens/day
                }
        }
     else{
         //10% of their deposit tokens will be sent to address  0x92370056813c5d147F5C77E973987006D5Ac508d
         transferFrom(_stakeholder,0x92370056813c5d147F5C77E973987006D5Ac508d,stakes[_stakeholder]*10/100);
     }   

    }


    function distributeRewards() 
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }


    function withdrawReward() 
        public
    { //Reward paid with RewardToken
        RewardToken RD = RewardToken(admin);
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        RD.transferFrom(admin, msg.sender, reward);

    }
}

abstract contract RewardToken is ERC20,Ownable {

}

abstract contract Stakeable is ERC20, Ownable{

}