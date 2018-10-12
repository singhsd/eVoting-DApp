pragma solidity ^0.4.0;

contract Voting {
    /// candidate structure
    /// votes have the total number of votes candidate secured
    struct Candidate {
        string name;
        // uint votes;
    }
    
        
    /// array of candidates
    Candidate[] candidates;
    /// mapping of voter to has_voted
    mapping(address => uint) voter;
    /// mapping of candidate to number_of_votes
    mapping(string => uint) votes;
    
    /// time and phase constants
    uint phase;
    uint candidate_registration_phase;
    uint voter_registration_phase;
    uint voting_phase;
    uint result_declaration_phase;
    
    constructor () public {
        phase = now;
        // define other phase constants here as seconds from epoch time,
        // but relative
    }
    
    function register_candidate(string name) public returns (uint status) {
        // check phase and return 0 if out of phase
        // also check if already exists
        Candidate memory newCandidate = Candidate(name); // ...name,0);
        candidates.push(newCandidate);
        votes[name] = 0;
        status = 1;
    }
    
    function register_voter() public returns (uint status) {
        // check phase and return 0 if out of phase
        // also check if already exists
        voter[msg.sender] = 0;
        status = 1;
    }
    
    function vote(string candidate_name) public returns (uint status) {
        // check phase and return 0 if out of phase
        // also check if already voted
        voter[msg.sender] = 1;
        votes[candidate_name]++;
        status = 1;
    }
    
    function get_results() public returns (string) {
        // check phase and return winner = "out of phase" if out of phase
       uint max_votes = 0;
       string memory winner = "None";
       uint n = candidates.length;
       for( uint i=0; i<n; i++)
       {
           if(max_votes < votes[candidates[i].name])
           {
               max_votes = votes[candidates[i].name];
               winner = candidates[i].name;
           }
           else if (max_votes == votes[candidates[i].name])
           {
               winner = "No definite winner";
           }
       }
       return winner;
    }
}