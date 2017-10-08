pragma solidity ^0.4.6;


contract tokenRecipient {function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);}


contract BULL {
    /* Public variables of the token */
    string public standard = 'Token 1.0';

    string public name = "BULL";

    string public symbol = "BULL";

    uint8 public decimals = 18;

    uint256 public totalSupply = 100000000000000000000000000;

    address public owner;
    
    bool mintingFinished = false;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function BULL() {
        balanceOf[msg.sender] = totalSupply;
        owner=msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }
    
    modifier canMint() {
        if(mintingFinished) revert();
        _;
    }
    
    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) revert();
        // Prevent transfer to 0x0 address
        if (balanceOf[msg.sender] < _value) revert();
        // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();
        // Check for overflows
        balanceOf[msg.sender] -= _value;
        // Subtract from the sender
        balanceOf[_to] += _value;
        // Add the same to the recipient
        Transfer(msg.sender, _to, _value);
        // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
    returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
    returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();
        // Prevent transfer to 0x0 address
        if (balanceOf[_from] < _value) revert();
        // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();
        // Check for overflows
        if (_value > allowance[_from][msg.sender]) revert();
        // Check allowance
        balanceOf[_from] -= _value;
        // Subtract from the sender
        balanceOf[_to] += _value;
        // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    

  /**
   * Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
   
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply += _amount;
    balanceOf[_to] += (_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    return true;
  }

}
