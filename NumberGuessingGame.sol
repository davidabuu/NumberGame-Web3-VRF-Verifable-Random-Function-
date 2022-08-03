// SPDX-License-Identifier: GPL-3.0
//Pending Tasks
//Step1: Let Mangager Set the number the chainlink randomess and send the money if it's correct
pragma solidity ^0.8.7;
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/interfaces/ KeeperCompatibleInterface.sol';
error NumberGuessingGame__NotEngoughEthEntered();
error NumberGuessingGame__NotAllowedToCallThisFunction();
contract NumberGuessingGame is VRFConsumerBaseV2 {
    //State Variables
    uint256 private immutable i_entranceFee;
    address private s_manager;
    address payable []  private s_players;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subcriptionId;
    uint16 private constant REQUEST_CONFRIMATIONS = 3; 
    uint32 private constant CALLBACK_LIMIT = 100000;
    uint32 private constant NUM_WORDS = 1;
    //Events
    event RequestId(uint256 indexed requestId);
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator; 
    constructor(address vrfCoordinatorV2, uint256 entranceFee, bytes32 gasLane, uint64 subcriptionId) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entranceFee = entranceFee;
        s_manager = msg.sender;
        i_vrfCoordinator = vrfCoordinatorV2;
        i_gasLane = gasLane;
        i_subcriptionId = subcriptionId;
    }
    modifier onlyOwner{
        require(msg.sender == s_manager, "You are not allowed to call this function");
        _;
    }
    function enterGame() public payable{
        if(msg.value < i_entranceFee){
            revert NumberGuessingGame__NotEngoughEthEntered();
        }
        s_players.push(payable(msg.sender));
    }
    //VRF Function to request The Random Number
    function requestRandomNumber()external onlyOwner{
    uint256 requestId = i_vrfCoordinator.requestRandomWords(
      gasLane,
      i_subcriptionId,
      REQUEST_CONFRIMATIONS,
      CALLBACK_LIMIT,
      NUM_WORDS
    );
     emit RequestId(requestId);
    }
    /*View /Pure Functions */ 
    function getEntranceFee() public view returns (uint256){
        return i_entranceFee;
    }
    //Get Players Length
    function totalNumberOfPlayers() public view returns (uint256){
        return s_players.length;
    }
}