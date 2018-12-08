// import CSS. Webpack with deal with it
import "../css/style.css"

// Import libraries we need.
import { default as Web3} from "web3"
import { default as contract } from "truffle-contract"

// get build artifacts from compiled smart contract and create the truffle contract
import votingArtifacts from "../../build/contracts/Voting.json"
var VotingContract = contract(votingArtifacts)

/*
 * This holds all the functions for the app
 */
window.App = {
  // called when web3 is set up
  start: function() { 
    // setting up contract providers and transaction defaults for ALL contract instances
    VotingContract.setProvider(window.web3.currentProvider)
    VotingContract.defaults({from: window.web3.eth.accounts[0],gas:6721975})

    // creates an VotingContract instance that represents default address managed by VotingContract
    VotingContract.deployed().then(function(instance){
    
      instance.getStartTime().then(function(start){
        var x=start;
        window.startTime = x.c[0];
        instance.getRegPhase().then(function(regPhase){
            var x=regPhase;
            window.regTime = x.c[0];
            instance.getVotePhase().then(function(votePhase){
                var x=votePhase;
                window.voteTime = x.c[0];
                var timeCheck1 = new Date(1000*(window.startTime+window.regTime))
                var timeCheck2 = new Date(1000*(window.startTime+window.regTime+window.voteTime))
                var string = "<p>Register candidates until "+timeCheck1.toString()+".</p><p>Vote for candidates after registration ends until "+timeCheck2.toString()+".</p><p>Get results after voting has ended</p><hr/>"
                $("#myHeading").html(string)
            });
        });
      });
      
      // calls getNumOfCandidates() function in Smart Contract, 
      // this is not a transaction though, since the function is marked with "view" and
      // truffle contract automatically knows this
      instance.getNumOfCandidates().then(function(numOfCandidates){

        // adds candidates to Contract if there aren't any
        if (numOfCandidates == 0){/*
          // calls addCandidate() function in Smart Contract and adds candidate with name "Candidate1"
          // the return value "result" is just the transaction, which holds the logs,
          // which is an array of trigger events (1 item in this case - "addedCandidate" event)
          // We use this to get the candidateID
          instance.addCandidate("Candidate1","Democratic").then(function(result){ 
            $("#candidate-box").append(`<div class='form-check'><input class='form-check-input' type='checkbox' value='' id=${result.logs[0].args.candidateID}><label class='form-check-label' for=0>Candidate1</label></div>`)
          })
          instance.addCandidate("Candidate2","Republican").then(function(result){
            $("#candidate-box").append(`<div class='form-check'><input class='form-check-input' type='checkbox' value='' id=${result.logs[0].args.candidateID}><label class='form-check-label' for=1>Candidate1</label></div>`)
          })
          // the global variable will take the value of this variable
          numOfCandidates = 2 
        */
        instance.addCandidate("None Of The Listed","None").then(function(result){ 
            $("#candidate-box").append(`<div class='form-check'><input class='form-check-input' type='checkbox' value='' id=${result.logs[0].args.candidateID}><label class='form-check-label' for=0>None Of The Listed</label></div>`)
          })
        numOfCandidates = 1
        }
        else { // if candidates were already added to the contract we loop through them and display them
          for (var i = 0; i < numOfCandidates; i++ ){
            // gets candidates and displays them
            instance.getCandidate(i).then(function(data){
              $("#candidate-box").append(`<div class="form-check"><input class="form-check-input" type="checkbox" value="" id=${data[0]}><label class="form-check-label" for=${data[0]}>${window.web3.toAscii(data[1])}</label></div>`)
            })
          }
        }
        // sets global variable for number of Candidates
        // displaying and counting the number of Votes depends on this
        window.numOfCandidates = numOfCandidates 
      })
    }).catch(function(err){ 
      console.error("ERROR! " + err.message)
    })
  },
  //function for registration of candidate.
  registerCandidate: function() {
    var nowTime = ((new Date).getTime())/1000
    if(nowTime > window.startTime + window.regTime){
        $("#msg").html("<p>Registration Period Ended.</p>")
        alert("Registration Period ended!")
      return
    }
    var uname = $("#id-input2").val()
    if (uname == ""){
      $("#msg").html("<p>Please enter name.</p>")
      return
    }
    $("#msg").html("")
    VotingContract.deployed().then(function(instance){
      
      instance.addCandidate(uname,"None").then(function(result){ 
            $("#candidate-box").append(`<div class='form-check'><input class='form-check-input' type='checkbox' value='' id=${result.logs[0].args.candidateID}><label class='form-check-label' for=0>${uname}</label></div>`)
          })
      
    }).catch(function(err){ 
      console.error("ERROR! " + err.message)
    })
  },

  // Function that is called when user clicks the "vote" button
  vote: function() {
    var nowTime = ((new Date).getTime())/1000
    if(nowTime < window.startTime + window.regTime){
        $("#msg").html("<p>Voting Period Not Started Yet.</p>")
        alert("Voting Period Not Started Yet");
      return
    }
    if(nowTime > window.startTime + window.regTime + window.voteTime){
        $("#msg").html("<p>Voting Period Ended.</p>")
        alert("Voting Period Ended.");
      return
    }
    $("#msg").html("")
    var uid = $("#id-input").val() //getting user inputted id

    // Application Logic 
    if (uid == ""){
      $("#msg").html("<p>Please enter id.</p>")
      return
    }
    // Checks whether a candidate is chosen or not.
    // if it is, we get the Candidate's ID, which we will use
    // when we call the vote function in Smart Contracts
    if ($("#candidate-box :checkbox:checked").length > 0){ 
      // just takes the first checked box and gets its id
      if ($("#candidate-box :checkbox:checked").length > 1) {
          $("#msg").html("<p>Please select only one candidate.</p>")
          alert("Please select only one candidate.");
          return
      }
      var candidateID = $("#candidate-box :checkbox:checked")[0].id
    } 
    else {
      // print message if user didn't vote for candidate
      $("#msg").html("<p>Please vote for a candidate.</p>")
      alert("Please vote for a candidate.");
      return
    }
    // Actually voting for the Candidate using the Contract and displaying "Voted"
    VotingContract.deployed().then(function(instance){
      instance.vote(uid,parseInt(candidateID)).then(function(result){
        $("#msg").html("<p>Voted</p>")
        alert("Voted");
      })
    }).catch(function(err){ 
      console.error("ERROR! " + err.message)
    })
  },

  // function called when the "Count Votes" button is clicked
  findNumOfVotes: function() {
    var nowTime = ((new Date).getTime())/1000
    if(nowTime < window.startTime + window.regTime + window.voteTime){
        $("#msg").html("<p>Voting Not Ended Yet.</p>")
        alert("Voting not ended yet.");
      return
    }
    $("#msg").html("")
    VotingContract.deployed().then(function(instance){
      // this is where we will add the candidate vote Info before replacing whatever is in #vote-box
      var box = $("<section></section>") 

      // loop through the number of candidates and display their votes
      for (var i = 0; i < window.numOfCandidates; i++){
        // calls two smart contract functions
        var candidatePromise = instance.getCandidate(i)
        var votesPromise = instance.totalVotes(i)

        // resolves Promises by adding them to the variable box
        Promise.all([candidatePromise,votesPromise]).then(function(data){
          box.append(`<p>${window.web3.toAscii(data[0][1])}: ${data[1]}</p>`)
        }).catch(function(err){ 
          console.error("ERROR! " + err.message)
        })
      }
      $("#vote-box").html(box) // displays the "box" and replaces everything that was in it before
    })
  }
}

// When the page loads, we create a web3 instance and set a provider. We then set up the app
window.addEventListener("load", function() {
  // Is there an injected web3 instance?
  if (typeof web3 !== "undefined") {
    console.warn("Using web3 detected from external source like Metamask")
    // If there is a web3 instance(in Mist/Metamask), then we use its provider to create our web3object
    window.web3 = new Web3(web3.currentProvider)
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:9545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for deployment. More info here: http://truffleframework.com/tutorials/truffle-and-metamask")
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://192.168.0.2:9545"))
  }
  // initializing the App
  window.App.start()
})
