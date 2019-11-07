pragma solidity ^0.4.24;


contract AccessControl {
    
    /// @dev The addresses of the accounts (or contracts) that can execute actions within each roles
    address public ceoAddress;
    address public cooAddress;

    /// @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev The AccessControl constructor sets the original C roles of the contract to the sender account
    constructor() public {
        ceoAddress = msg.sender;
        cooAddress = msg.sender;
    }

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    /// @dev Access modifier for any CLevel functionality
    modifier onlyCLevel() {
        require(msg.sender == ceoAddress || msg.sender == cooAddress);
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) public onlyCEO {
        require(_newCOO != address(0));
        cooAddress = _newCOO;
    }

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Pause the smart contract. Only can be called by the CEO
    function pause() public onlyCEO whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Only can be called by the CEO
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}


/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}



/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface ERC721 /* is ERC165 */ {

    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    
    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    /// For querying balance of a particular account.
    /// @param _owner The address for balance query.
    /// @dev Required for ERC-721 compliance.
    function balanceOf(address _owner) external view returns (uint256 _balance);

    /// For querying owner of token.
    /// @param _tokenId The tokenID for owner inquiry.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId) external view returns (address _owner);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    
    /// Third-party initiates transfer of token from address _from to address _to.
    /// @param _from The address for the token to be transferred from.
    /// @param _to The address for the token to be transferred to.
    /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;
    
    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);
    
    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}


/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface ERC721Metadata /* is ERC721 */ {
    
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string);
}


contract ValidReceiver is ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    } 
}

contract InvalidReceiver is ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
        return bytes4(keccak256("some invalid return data"));
    } 
}


interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x780e9d63
interface ERC721Enumerable /* is ERC721 */ {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}


contract CheckERC165 is ERC165 {
    mapping (bytes4 => bool) internal supportedInterfaces;

    /* bytes4(keccak256('supportsInterface(bytes4)')) === 0x01ffc9a7 */  
    bytes4 public constant Interface_ERC165 = 0x01ffc9a7;

    constructor() public {
        supportedInterfaces[Interface_ERC165] = true;
    }
    
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool){
        require(interfaceID != 0xffffffff);
        return supportedInterfaces[interfaceID];
    }   
}



contract ChampionCards is AccessControl, ERC721 , CheckERC165 , ERC721Metadata  {
    
    using SafeMath for uint256;
    using Strings for string;

    mapping (uint256 => address) private tokenIdToOwner;
    mapping (address => uint256) private ownershipTokenCount;
    mapping (address => uint256) private ownershipPackCount;
    mapping (address => uint256) public referToOwner;
    mapping (uint256 => address) private tokenIdToApproved;
    mapping (uint256 => address) private packIdToOwner;
    mapping (address => mapping (address => bool)) internal authorised;

    Card[] public cards;
    struct Card {
        uint8 rarity;
        uint seq;
    }
    
    event UnboxReceived (
        uint8[] rarity, 
        uint64[] seq,
        uint curSupply,
        uint endSupply
    ); 
    
    Pack[] public packs;
    
    struct Pack {
        uint8 ptype;
        uint32 count;
        uint scard;
        uint tcard;
        uint commit;
        uint randomness;
        address owner; 
        uint value; 
    }
    
    uint64 private uncommonSeq = 1; 
    uint32 private rareSeq = 1; 
    uint32 private epicSeq = 1;
    uint24 private mythicSeq = 1;
    uint24 private legendarySeq = 1;
    uint16 private shinySeq = 1;
    uint32 private promoSeq = 1; 
    uint32 private futureRandCommit = 1; 
    uint16 private pCommit = 1; 
    
    uint256 public constant uncommonMax = 65000; 
    uint256 public constant rareMax = 75000; 
    uint256 public constant epicMax = 35000;    
    uint256 public constant mythicMax = 19000;
    uint256 public constant legendaryMax = 5500;
    uint256 public constant shinyMax = 4;
    uint maxSupply = 210000; // total number of ERC-721 tokens must not exceed 
    uint256 public constant promoMax = 15000; // max amount of cards for promo
    uint8 referPercent = 15; 
    
    uint private uncommonPackPrice = 30000000000000000; 
    uint private rarePackPrice = 30000000000000000; 
    uint private epicPackPrice = 90000000000000000; 
    uint private mythicPackPrice = 300000000000000000; 
    uint private shinyPackPrice = 1000000000000000000;
    
    bytes4 private constant Interface_ERC721 = 0x80ac58cd;
    bytes4 private constant Interface_ERC721Metadata = 0x5b5e139f;
    bytes4 private constant Interface_ERC721Enumerable = 0x780e9d63;
    
    string public tokenBaseURI = "https://www.cryptochampions.co/api/c/";

    constructor() public CheckERC165(){

        // Mint a single genesis card and pack to burn initial index   
        Card memory _card = Card({
            rarity: 0, 
            seq: 0 
        }); 
        uint _cardId = cards.push(_card) - 1;
        ownershipTokenCount[address(0)]++;
        tokenIdToOwner[_cardId] = address(0);
        tokenIdToApproved[_cardId];
         
        uint64 _bnumber = uint64( block.number );
        uint _rand = random( _bnumber );
        Pack memory _pack = Pack({
            ptype: 2,
            count: 1,
            scard:0, 
            tcard:0,
            commit: _bnumber, 
            randomness: _rand,
            owner:address(0), 
            value:1 
        });
    
        uint _packId = packs.push(_pack) - 1; 
        packIdToOwner[_packId] = address(0);
        ownershipPackCount[address(0)]++;
         
        supportedInterfaces[Interface_ERC721] = true;
        supportedInterfaces[Interface_ERC721Metadata] = true;
        supportedInterfaces[Interface_ERC721Enumerable] = true;

    }
    
    // Metadata base URI is adjustable as needed 
    function changeBaseURI(string _newBaseURI) public onlyCEO whenNotPaused{
        tokenBaseURI = _newBaseURI;
    }
    
    // Refer percentage is adjustable only by the publisher of the contract 
    function changeReferPercent(uint8 _newPercent ) public onlyCEO whenNotPaused{
        require ( _newPercent > 3 && _newPercent < 36 );  
        referPercent = _newPercent;
    }

    function name() external view returns (string _name) {
        _name = "CryptoChampions";
    }

    function symbol() external view returns (string _symbol) {
        _symbol = "CC";
    }
    
    function tokenURI(uint256 _tokenId) external view returns (string){
        return Strings.strConcat(
            tokenBaseURI,
            Strings.uint2str(_tokenId)
        );
    }
    
     
    function setRate( uint _uncommonPackPrice , uint _rarePackPrice , uint _epicPackPrice
    , uint _mythicPackPrice , uint _shinyPackPrice ) public onlyCEO whenNotPaused {
        uncommonPackPrice = _uncommonPackPrice; 
        rarePackPrice = _rarePackPrice;
        epicPackPrice = _epicPackPrice;
        mythicPackPrice = _mythicPackPrice;
        shinyPackPrice = _shinyPackPrice;
    }
    
    function commitCallback(uint32 _commit ) public onlyCEO whenNotPaused {
        futureRandCommit = _commit; 
    }
    
    function setPCommit(uint16 _commit ) public payable whenNotPaused {
        pCommit = _commit; 
    }
    
    function tokensOf(address _owner) public view returns(uint256[]) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 total = totalSupply();
            uint256 resultIndex = 0;

            for (uint256 i = 0; i < total; i++) {
                if (tokenIdToOwner[i] == _owner) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
    }
    
    // return all packs owned by an address 
    function packsOf(address _owner) public view returns(uint256[]) {
        
        uint256 packCount = packCountOf(_owner);
            
        if (packCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](packCount);
            uint256 total = totalPacks();
            uint256 resultIndex = 0;

            for (uint256 i = 0; i < total; i++) {
                if (packIdToOwner[i] == _owner) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
        
    }

    // use numbers unable to be manipulated by end user 
    function random( uint64 _bnumber ) private view returns (uint) {
        return uint(keccak256(abi.encodePacked( futureRandCommit , pCommit , _bnumber , cards.length , packs.length ,
        uncommonSeq , rareSeq )));
    }
    
    // use numbers unable to be manipulated by end user 
    function randomShort( uint64 _bnumber , uint _varCount ) private view returns (uint) {
        
        uint _thisVarCount = _varCount + 4; 
        uint _random = uint(keccak256(abi.encodePacked( futureRandCommit , pCommit , _bnumber, _thisVarCount,  cards.length , packs.length ,
        uncommonSeq , rareSeq , epicSeq ,  mythicSeq , legendarySeq , shinySeq ))) % 10000000000;
        return _random;
    }

    // determine rarity token 
    function getRarity( uint8 _packType , uint _rand ) internal view returns( uint8 ){ 
        
            uint8 _rarity; 

            if( _packType == 1){
                if( _rand > 993000 && legendarySeq <= legendaryMax ){
                    _rarity = 6;
                }else if( _rand > 975000 && mythicSeq <= mythicMax){
                    _rarity = 5;
                }else if( _rand > 950000 && epicSeq <= epicMax ){
                        _rarity = 4;
                }else if( _rand > 920000 && rareSeq <= rareMax ){
                        _rarity = 3;
                }else if( _rand > 860000 && uncommonSeq <= uncommonMax ){
                        _rarity = 2;
                }else{
                    _rarity = 1; 
                } 
            }else if( _packType == 2){ // Rare Pack 
                if( _rand > 992000 && legendarySeq <= legendaryMax ){
                    _rarity = 6;
                }else if( _rand > 978000 && mythicSeq <= mythicMax){
                    _rarity = 5;
                }else if( _rand > 962000 && epicSeq <= epicMax ){
                        _rarity = 4;
                }else if( _rand > 924000 && rareSeq <= rareMax ){
                        _rarity = 3;
                }else if( _rand > 876000 && uncommonSeq <= uncommonMax ){
                        _rarity = 2;
                }else{
                    _rarity = 1; 
                }
            }else if( _packType == 3 ){ // Epic Pack 
                if( _rand > 986000 && legendarySeq <= legendaryMax ){
                    _rarity = 6; 
                }if( _rand > 950000 && mythicSeq <= mythicMax ){
                    _rarity = 5; 
                }else if( _rand > 920000 && epicSeq <= epicMax ){
                    _rarity = 4; 
                }else if( _rand > 890000 && rareSeq <= rareMax ){
                    _rarity = 3; 
                }else if( _rand > 840000 && uncommonSeq <= uncommonMax){
                    _rarity = 2; 
                }else{
                    _rarity = 1; 
                }
            }else if( _packType == 4 ){ // Mythic Pack 
                if( _rand > 999998  && shinySeq <= shinyMax){
                    _rarity = 7;    
                }else if( _rand > 980000 && legendarySeq <= legendaryMax ){
                    _rarity = 6; 
                }if( _rand > 940000 && mythicSeq <= mythicMax){
                    _rarity = 5; 
                }else if( _rand > 890000 && epicSeq <= epicMax){
                    _rarity = 4; 
                }else if( _rand > 830000 && rareSeq <= rareMax ){
                    _rarity = 3; 
                }else if( _rand > 700000 && uncommonSeq <= uncommonMax){
                    _rarity = 2; 
                }else{
                    _rarity = 1; 
                }
            }else if( _packType == 5){ // Shiny Pack 
                if( _rand > 999994 && shinySeq <= shinyMax ){
                    _rarity = 7;    
                }else if( _rand > 940000  && legendarySeq <= legendaryMax){
                    _rarity = 6; 
                }if( _rand > 900000 && mythicSeq <= mythicMax){
                    _rarity = 5; 
                }else if( _rand > 820000 && epicSeq <= epicMax){
                    _rarity = 4; 
                }else if( _rand > 750000 && rareSeq <= rareMax){
                    _rarity = 3; 
                }else if( _rand > 580000 && uncommonSeq <= uncommonMax){
                    _rarity = 2; 
                }else{
                    _rarity = 1; 
                }
            }
        
       return ( _rarity ); 
       
    }
    
    
    // Mint a promo pack ( so long as promo packs are available within limit )
    function promoPack( uint8 _packType , address _to ) public onlyCEO whenNotPaused {
        
        require(msg.sender != address(0));
        require(_to != address(0));
        require( promoSeq < promoMax ); 
        require(_packType > 0 && _packType < 6); 

        uint64 _bnumber = uint64( block.number );
        uint curSupply = totalSupply(); 
        
        unpackCards( 1 , _packType , _to , _bnumber , curSupply );
    
        uint endSupply = totalSupply(); 
        
        uint _rand = random( _bnumber );
        Pack memory _pack = Pack({
            ptype: _packType,
            count: 1,
            scard: curSupply, 
            tcard: endSupply,
            commit: _bnumber, 
            randomness: _rand,
            owner: _to, 
            value: 1 
        });

        uint _packId = packs.push(_pack) - 1; 
        packIdToOwner[_packId] = _to;
        ownershipPackCount[_to]++;
         
        promoSeq++; 

    }
    
    function getCardInfo() public view onlyCEO returns( uint64 , uint32 , uint32 , uint24 , uint24 , uint16 , uint32 )  {
        
        return( 
            uncommonSeq , rareSeq ,  epicSeq, 
            mythicSeq , legendarySeq , shinySeq, 
            promoSeq 
        ); 
    }
    
    
    function getPModel() public view onlyCEO returns( uint , uint , uint , uint , uint )  {
        return( 
            uncommonPackPrice, rarePackPrice , epicPackPrice ,  mythicPackPrice, shinyPackPrice 
        ); 
    }
    
    // Main function for acquiring a card pack 
    // Only cards selected as uncommon and above rarity will be minted to save gas 
    // If refered pass a value to referrer 
    // Run through security checks and store block commited 
    function purchasePack( uint8 _packType , uint16 _packCount , address _referer ) public payable whenNotPaused {
        
        require(msg.sender != address(0));
        require(_packCount > 0 && _packCount < 51);
        require(_packType > 0 && _packType < 6); 
    
        uint _totalPrice; 

        if( _packType == 1 ){
            _totalPrice = ( uncommonPackPrice * _packCount );
            require(msg.value >= _totalPrice);
        }else if( _packType == 2 ){
            _totalPrice = ( rarePackPrice * _packCount );
            require(msg.value >= _totalPrice);
        }else if( _packType == 3 ){
            _totalPrice = ( epicPackPrice * _packCount );
            require(msg.value >= _totalPrice);
        }else if( _packType == 4 ){
            _totalPrice = ( mythicPackPrice * _packCount );
            require(msg.value >= _totalPrice);   
        }else if( _packType == 5 ){
            _totalPrice = ( shinyPackPrice * _packCount );
            require(msg.value >= _totalPrice);
        }else{
            revert(); 
        }
        require( _totalPrice > 0 ); 

        uint64 _bnumber = uint64( block.number );
        uint curSupply = totalSupply(); 
        
        unpackCards( _packCount , _packType , msg.sender , _bnumber , curSupply );
        
        uint endSupply = totalSupply(); 
                
        uint _rand = random( _bnumber );
        Pack memory _pack = Pack({
            ptype: _packType,
            count: _packCount,
            scard: curSupply, 
            tcard: endSupply,
            commit: _bnumber, 
            randomness: _rand,
            owner: msg.sender, 
            value: _totalPrice
        }); 
        
        uint _packId = packs.push(_pack) - 1; 
        packIdToOwner[_packId] = msg.sender;
        ownershipPackCount[msg.sender]++;
        
        if( _referer != address(0) && _referer != msg.sender){
            uint refValue = ( _totalPrice * 15 ) / 100;
            address(_referer).transfer(refValue);
            referToOwner[_referer] = referToOwner[_referer] + refValue; 
        }
        
    }
    
    
    function getSeq( uint8 _rarity ) private returns( uint64 ){
        
        uint64 _seq; 
        if( _rarity == 1){
            _seq = 1; 
        }else if(_rarity == 2){
            _seq = uncommonSeq;
            uncommonSeq++; 
        }else if(_rarity == 3){
            _seq = rareSeq; 
            rareSeq++; 
        }else if(_rarity == 4){
            _seq = epicSeq; 
            epicSeq++; 
        }else if(_rarity == 5){
            _seq = mythicSeq;
            mythicSeq++; 
        }else if(_rarity == 6 ){
            _seq = legendarySeq;
            legendarySeq++; 
        }else if(_rarity == 7){
            _seq = shinySeq; 
            shinySeq++; 
        }
                    
        return _seq; 
    }                
    
    // Gets the next rarity available in case rarity levels reach cap 
    // 
    function getPackRarity( uint8 _packType ) private view returns( uint8 ){
        
        uint8 _rarity; 
        
        if( _packType >= 5 && legendarySeq <= legendaryMax ){
            _rarity = 6;
        }else if( _packType >= 4 && mythicSeq <= mythicMax ){
            _rarity = 5; 
        }else if( _packType >= 3 && epicSeq <= epicMax ){
            _rarity = 4;
        }else if( _packType >= 2 && rareSeq <= rareMax ){
            _rarity = 3;  
        }else if( _packType >= 1 && uncommonSeq <= uncommonMax ){
            _rarity = 2; 
        }else {
            _rarity = 1;
        }

        return _rarity; 
    }
    
    // opens the pack of cards and mints uncommons and above 
    // transfer ownership of each minted card 
    // return a callback to subscribed unbox received function
    function unpackCards( uint16 _packCount , uint8 _packType , address _to , uint64 _commit , uint _curSupply ) private whenNotPaused {
        
        for( uint8 i = 0; i < _packCount; i++ ){
            
            uint8[] memory _rares = new uint8[](5);
            uint64[] memory _seqs = new uint64[](5);

            for( uint8 x = 0; x < 5; x++ ){
                
                uint thisRand = ( randomShort( _commit , x ) * ( x + 1 )) % 1000000; 
                uint8 _rarity; 

                if( x == 4 ){
                    _rarity = getPackRarity( _packType ); 
                }else{
                    _rarity = getRarity( _packType , thisRand );
                }
                uint64 _seq = getSeq( _rarity );
                
                if( _rarity > 1 ){
                    Card memory _card = Card({
                        rarity: _rarity, 
                        seq: _seq 
                    }); 
                    uint _cardId = cards.push(_card) - 1;
                    
                    ownershipTokenCount[_to]++;
                    tokenIdToOwner[_cardId] = _to;
                    
                    emit Transfer( address(0) , _to , _cardId ); 
                }
                
                _rares[x] = _rarity; 
                _seqs[x] = _seq; 
                
            }
            
            uint _endSupply = totalSupply(); 
            emit UnboxReceived( _rares , _seqs , _curSupply , _endSupply );
            
        } 
        
    }
    
                    
    function isValidToken(uint256 _tokenId) internal view returns(bool){
        return _tokenId != 0 && _tokenId <= maxSupply;
    }

    function totalPacks() public view returns (uint256 _totalPacks) {
        _totalPacks = packs.length;
    }
    
    function packCountOf(address _owner) public view returns (uint256 _packCount) {
        _packCount = ownershipPackCount[_owner];
    }
    
    function totalSupply() public view returns (uint256 _totalSupply) {
        _totalSupply = cards.length;
    }
    
    function tokenByIndex(uint256 _index) external view returns(uint256){
        require(_index < cards.length);
        return _index;
    }
    
    
    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){
        
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return 0;
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 total = totalSupply();
            uint256 resultIndex = 0;

            for (uint256 i = 0; i < total; i++) {
                if (tokenIdToOwner[i] == _owner) {
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result[_index];
        }
        
    }

    
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        _balance = ownershipTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        require(isValidToken(_tokenId));
        _owner = tokenIdToOwner[_tokenId];
    }


    function approve(address _approved, uint256 _tokenId) public whenNotPaused{
            
        address owner = ownerOf(_tokenId);
        require( owner == msg.sender || authorised[owner][msg.sender] );
        
        emit Approval(msg.sender, _approved, _tokenId);
        tokenIdToApproved[_tokenId] = _approved;
        
    }
    
    
    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable {
        transferFrom(_from, _to, _tokenId);

        //Get size of "_to" address, if 0 it's a wallet
        uint32 size;
        assembly {
            size := extcodesize(_to)
        }
        if(size > 0){
            ERC721TokenReceiver receiver = ERC721TokenReceiver(_to);
            require(receiver.onERC721Received(msg.sender,_from,_tokenId,data) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }

    }
    
    
    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        safeTransferFrom(_from,_to,_tokenId,"");
    }
    
    
    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all your assets.
    /// @dev Emits the ApprovalForAll event
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operators is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external {
        
        emit ApprovalForAll(msg.sender,_operator, _approved);
        authorised[msg.sender][_operator] = _approved;
    }
    
    
    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return authorised[_owner][_operator];
    }
    
    
    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address) {
        require(isValidToken(_tokenId));
        return tokenIdToApproved[_tokenId];
    }


    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
        
        require(_to != address(0));
        
        address owner = ownerOf(_tokenId);
        
        require ( owner == msg.sender || tokenIdToApproved[_tokenId] == msg.sender || authorised[owner][msg.sender] );
        require ( owner == _from );
        require(_to != 0x0);

        _transfer(_from, _to, _tokenId);
    }
    
    
    function checkOwner( uint256 _tokenId) public view whenNotPaused returns ( address ){
        
        address owner = ownerOf(_tokenId);
        return owner; 
    }
    
    
    function showBalance() public view onlyCEO returns( uint256 ){
        return (address(this).balance);
    }
    
    function withdrawBalance(address _to, uint256 _amount) public onlyCEO {
        require(_amount <= address(this).balance);

        if (_amount == 0) {
            _amount = address(this).balance;
        }

        if (_to == address(0)) {
            ceoAddress.transfer(_amount);
        } else {
            _to.transfer(_amount);
        }
        
    }

    function _owns(address _claimant, uint256 _tokenId) public view returns (bool) {
        return tokenIdToOwner[_tokenId] == _claimant;
    }

    function _approved(address _to, uint256 _tokenId) private view returns (bool) {
        return tokenIdToApproved[_tokenId] == _to;
    }


    function _transfer(address _from, address _to, uint256 _tokenId) private {
        
        ownershipTokenCount[_to]++;

        tokenIdToOwner[_tokenId] = _to;

        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete tokenIdToApproved[_tokenId];
        }

        emit Transfer(_from, _to, _tokenId);
        
    }

    
}



library Strings {
    
  // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
  function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint i) internal pure returns (string) {
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}




library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
