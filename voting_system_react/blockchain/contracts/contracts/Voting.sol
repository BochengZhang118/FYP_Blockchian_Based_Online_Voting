// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;




contract Voting {  

    struct Voter{
        bytes32 name;
        uint32 weight;
        mapping(uint => uint) vote;
        mapping(uint => bool) voted;
       
    }


    struct activity{
        uint id;
        bytes activityName;
        bytes describe;
        bytes[] proposalName;
        bytes32 password;
        uint256[] voteCount;
        address chairperson;
        address[] voterAddress;
    }

    address public chairperson;
 
                                                                                                            
    mapping(uint => activity)public activities;

    mapping(address=>Voter) voters;                                                                                                                        // 在solidity中，mapping没有长度length的概念，也无法使用set来设置或者添加映射值的必要。
    
    uint sum=0;
    uint public activityCount = 0;

    uint256[] _voteCount;

    function creatActivity(bytes memory _activityName,bytes memory _password, bytes memory acDescribe,bytes[] memory _proposalNames,address[] memory _voterAddress) external {
        _voteCount =new uint256[](_proposalNames.length) ;
        chairperson =msg.sender;
        
      
        for(uint i=0;i<_voterAddress.length;i++){
            voters[_voterAddress[i]].weight +=1;
        }
        activityCount ++;
        voters[chairperson].voted[activityCount]=false;
        activities[activityCount]=activity(activityCount,_activityName,acDescribe,_proposalNames,keccak256(_password),_voteCount,chairperson,_voterAddress);
        
    }

    function getActivity(uint acId) public view returns(activity memory _activity){
        
        _activity = activities[acId];
    }
   
    function getVoter(uint acID,address voter) public view returns(uint _id){
        
        _id = voters[voter].vote[acID];
    }

    // function applyRight(address _voter,uint _acId ) external view{
    //     require(!voters[_voter].voted[_acId],"The voter already voted.");
    //     require(voters[_voter].weight==0);//或者把voter的信息给client前端比对
    // } 

    function giveRightToVoter(address _voter) external{
        //require(msg.sender==chairperson, "Only chairperson can give right to vote.");
        voters[_voter].weight +=1;//bool
    }

    
    function vote(uint acID,uint _proposal) external {                                                                                                        //能投的proposal在前端显示 voter不能投不存在的
        Voter storage sender =voters[msg.sender];
        require (!sender.voted[acID], "Already voted");
        //要解封
        // require (sender.weight==1, "You cannot vote");

        sender.voted[acID]=true;
        sender.vote[acID]=_proposal+1;
        activity storage _activity = activities[acID];
        _activity.voteCount[_proposal]++;
        sender.weight --;
    }

    function numberOfVoteForProposal (uint acID,uint32 _propID) external view returns (uint){

        return activities[acID].voteCount[_propID];
    }

    // function checkVotingRecord (uint _acID) external view returns(uint){
    //     require(voters[msg.sender].voted[_acID],"Not yet voted");
    //     return voters[msg.sender].vote;
    // }

    function getWinner(uint acID) external view returns ( bytes memory _winnerName){
        uint winnerCount = 0;

        activity memory  _ac = activities[acID];
        for(uint i = 0; i<_ac.proposalName.length;i++){
            if(_ac.voteCount[i]>winnerCount){
                winnerCount=_ac.voteCount[i];
                _winnerName=_ac.proposalName[i];
            }
        }
        if (winnerCount == 0) _winnerName="No one has voted yet";
    }

    function passwordVerification(uint id, bytes memory _password) external view returns(bool){
        return keccak256(_password) == activities[id].password;
    }
    

}
