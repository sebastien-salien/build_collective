pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  struct Entreprise {
    string name;
    address owner;
    address[] membersAddresses;
    uint256 balance;
  }

  struct Projet {
    uint256 id;
    string name;
    address owner;
    bool isUser;
    address[] contributorsAddresses;
    uint256 balance;
  }

  address[] public userAddresses;
  uint256 internal projetId;

  mapping(address => User) private users; // user's address -> User

  mapping(address => Entreprise) private enterprises; // owner's address -> owner's enterprise

  mapping(address => Projet[]) private projets; // projet's owner's address -> owner's projets

  event UserSignedUp(address indexed userAddress, User indexed user);

  event CreatedEntreprise(address indexed ownerAddress, Entreprise indexed entreprise);

  event CreatedProjet(address indexed ownerAddress, Projet indexed projet);

  function user(address userAddress) public view returns (User memory) {
    require(users[userAddress].registered);
    return users[userAddress];
  }

  function signUp(string memory username, uint256 amount) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, amount, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    userAddresses.push(msg.sender);
    return users[msg.sender];
  }

  function getAllUsers() external view returns (address[] memory) {
    return userAddresses;
  }

  function entreprise(string memory name, address[] memory membersList, uint256 amount) public returns (Entreprise memory) {
    require(users[msg.sender].registered);
    require(bytes(name).length > 0);
    enterprises[msg.sender] = Entreprise(name, msg.sender, membersList, amount);
    emit CreatedEntreprise(msg.sender, enterprises[msg.sender]);
    return enterprises[msg.sender];
  }

  function getEntreprise(address enterpriseAddress) public view returns (Entreprise memory) {
    require(users[enterpriseAddress].registered);
    return enterprises[enterpriseAddress];
  }

  function projet(string memory name, bool isUser, address[] memory contributorsList, uint256 amount) public returns (Projet memory){
    require(users[msg.sender].registered);
    require(bytes(name).length > 0);
    projetId ++;
    Projet memory proj = Projet(projetId, name, msg.sender, isUser, contributorsList, amount);
    projets[msg.sender].push(proj);
    emit CreatedProjet(msg.sender, proj);
    return proj;
  }

  function getProjet(address projetAddress) public view returns (Projet[] memory){
    require(users[projetAddress].registered);
    return projets[projetAddress];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  function getBalance() public view returns(uint) {
    return address(this).balance;
  }
}  
