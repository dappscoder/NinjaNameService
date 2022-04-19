pragma solidity >=0.8.4;
// ライセンス:商用利用禁止、責任免除、著作権表示必要
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtils.sol";
import "./library.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract NinjaNameService is  Ownable,ERC721Enumerable  {
    address proxyRegistryAddress;
    using StringUtils for *;
    using strings for *;
    uint256 private latestTokenId;

    address private stuffaccount;
    address private withdrawaccount;

    uint private price7;
    uint private price6;
    uint private price5;
    uint private price4;
    uint private price3;
    uint private price2;
    uint private price1;

    uint private timer1;
    uint private timer2;
    uint private timer3;
    uint private timer4;
    uint private timer5;
    uint private timer6;
    uint private timerall;

    mapping (uint => uint) expiries;//tokenid=>period
    mapping (string => uint) private domainid;//name=>tokenid
    mapping (uint=>string) private reverseDomain;//tokenid=>name
    mapping (string => mapping(string=>string)) private data;//name=>category=>data

    event DomainGet(string _name,address _owner,uint expiries);
    event Renew(string _name,address _owner,uint expiries);
    event SubDomainGet(uint indexed tokenid,string _subname);
    event DataSet(string _name,string _category,string _info);

    constructor(address _proxyRegistryAddress) ERC721("NinjaNameService","NNS") {
       proxyRegistryAddress = _proxyRegistryAddress;
        latestTokenId = 1;
        price7 = 1486000000000000;//単位はwei (5$/3363$)*toWei
        price6 = 1486000000000000;//5$
        price5 = 1486000000000000;//5$
        price4 = 47552000000000000;//160$
        price3 = 190208000000000000;//640$
        price2 = 760832000000000000;//2560$
        price1 = 3043328000000000000;//10240$
        timer6 = 1680470972;//2023-04-03 06:29:32(JP)
        timer5 = 1685741372;//2023-06-03 06:29:32
        timer4 = 1691011772;//2023-08-03 06:29:32
        timer3 = 1696282172;//2023-10-03 06:29:32
        timer2 = 1712093372;//2024-04-03 06:29:32
        timer1 = 1717363772;//2024-06-03 06:29:32
        timerall = 1650759853;//4/24 9:24
        stuffaccount = 0x9C120a8161b0dE8Ed1Be9FD19870f0a0257AF8Dc;
        withdrawaccount = 0xB0C00Be445c3ca7F65E8275389c583Ad29008c49;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function ownerOf(uint256 tokenId) public view override(ERC721) returns (address) {
        require(expiries[tokenId] > block.timestamp);
        return super.ownerOf(tokenId);
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        require(expiries[tokenId] > block.timestamp);
        return ERC721.getApproved(tokenId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        uint tid = ERC721Enumerable.tokenOfOwnerByIndex(owner,index);
        require(owner == ownerOf(tid),"Domain Expired!");
        return tid;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        //require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        uint tid = ERC721Enumerable.tokenByIndex(index);
        require(expiries[tid] > block.timestamp,"Domain Expired!");
        return tid;
    }

    function nameExpires(uint256 id) external view returns(uint) {
        return expiries[id];
    }

    function available(uint256 id) public view returns(bool) {
        
        return expiries[id] < block.timestamp;
    }

     function baseTokenURI() public view returns (string memory) {
        return "https://ninjanameservice.net/api2.php?name=";
    }

     /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        string memory n = reverseDomain[_tokenId];
        return string(abi.encodePacked(baseTokenURI(), n));
    }

    function mint(string memory name) external payable{
        require(subcheck(name) == true);
        require(spacecheck(name) == true);
        require(bigspacecheck(name) == true);
        uint len = name.strlen();
        if(domainid[name] == 0){//未登録
           if(len == 1){
                require(timer1 < block.timestamp);
                require(msg.value == price1);
                getname(name,msg.sender);
            }else if(len == 2){
                require(timer2 < block.timestamp);
                require(msg.value == price2);
                getname(name,msg.sender);
            }else if(len == 3){
                require(timer3 < block.timestamp);
                require(msg.value == price3);
                getname(name,msg.sender);
                
            }else if(len == 4){
                require(timer4 < block.timestamp);
                require(msg.value == price4);
                getname(name,msg.sender);
            }else if(len ==5){
                require(timer5 < block.timestamp);
                require(msg.value == price5);
                getname(name,msg.sender);
            }else if(len ==6){
                require(timer6 < block.timestamp);
                require(msg.value == price6);
                getname(name,msg.sender);
            }else if(len >= 7){
                require(timerall < block.timestamp);
                require(msg.value == price7);
                getname(name,msg.sender);
            }

        }else if(domainid[name] != 0 && available(domainid[name])==true){
            //登録済みだが期限切れ
            if(len == 1){
                require(timer1 < block.timestamp);
                require(msg.value == price1);
                Regetname(name,msg.sender);
            }else if(len == 2){
                require(timer2 < block.timestamp);
                require(msg.value == price2);
                Regetname(name,msg.sender);
            }else if(len == 3){
                require(timer3 < block.timestamp);
                require(msg.value == price3);
                Regetname(name,msg.sender);
                
            }else if(len == 4){
                require(timer4 < block.timestamp);
                require(msg.value == price4);
                Regetname(name,msg.sender);
                
            }else if(len ==5){
                require(timer5 < block.timestamp);
                require(msg.value == price5);
                Regetname(name,msg.sender);
            }else if(len == 6){
                require(timer6 < block.timestamp);
                require(msg.value == price6);
                Regetname(name,msg.sender);
            }else if(len >= 7){
                require(timerall < block.timestamp);
                require(msg.value == price7);
                Regetname(name,msg.sender);
            }
        }
    }

    function getname(string memory name,address owner) private {
        uint256 tokenId = latestTokenId;
        _mint(owner, tokenId);
        domainid[name] = tokenId;
        reverseDomain[tokenId] = name;
        expiries[tokenId] = block.timestamp + 365 days;
        latestTokenId++;
        emit DomainGet(name,owner,expiries[tokenId]);
    }

    function Regetname(string memory name,address owner) private{
        uint x = domainid[name];
        _burn(x);
        _mint(owner, x);
        expiries[x] = block.timestamp + 365 days;//365 days
        emit DomainGet(name,owner,expiries[x]);
    }

    function renew(string memory name) external payable{
        require(ownerOf(domainid[name]) == msg.sender);//ドメイン所有者かつ期限内
        require(subcheck(name) == true);//サブドメインではない
        uint len = name.strlen();
        if(len == 1){
            require(msg.value == price1);
            expiries[domainid[name]] = expiries[domainid[name]] + 365 days;//1年延長
            emit Renew(name,msg.sender,expiries[domainid[name]]);
        }else if(len == 2){
            require(msg.value == price2);
            expiries[domainid[name]] = expiries[domainid[name]] + 365 days;
            emit Renew(name,msg.sender,expiries[domainid[name]]);
        }else if(len == 3){
            require(msg.value == price3);
            expiries[domainid[name]] = expiries[domainid[name]] + 365 days;
            emit Renew(name,msg.sender,expiries[domainid[name]]);
        }else if(len == 4){
            require(msg.value == price4);
            expiries[domainid[name]] = expiries[domainid[name]] + 365 days;
            emit Renew(name,msg.sender,expiries[domainid[name]]);
        }else if(len ==5){
            require(msg.value == price5);
            expiries[domainid[name]] = expiries[domainid[name]] + 365 days;
            emit Renew(name,msg.sender,expiries[domainid[name]]);
        }else if(len ==6){
            require(msg.value == price6);
            expiries[domainid[name]] = expiries[domainid[name]] + 365 days;
            emit Renew(name,msg.sender,expiries[domainid[name]]);
        }else if(len >=7){
            require(msg.value == price7);
            expiries[domainid[name]] = expiries[domainid[name]] + 365 days;
            emit Renew(name,msg.sender,expiries[domainid[name]]);
        }
    }

    function subdomainset(string memory name,string memory sub) external{
        require(ownerOf(domainid[name]) == msg.sender);
        require(subcheck(sub) == true);
        string memory x = string(abi.encodePacked(sub, "."));
        string memory subdomain = string(abi.encodePacked(x, name));
        domainid[subdomain] = domainid[name];
        emit SubDomainGet(domainid[name],subdomain);
    }

    function dataset(string memory name,string memory category,string memory info) external {
        require(ownerOf(domainid[name]) == msg.sender);
        data[name][category] = info;
        emit DataSet(name,category,info);
    }

    function datacall(string memory name,string memory category) external view returns(string memory){
        if(expiries[domainid[name]] > block.timestamp){
            return data[name][category];
        }else{//期限切れもしくは、取得されていない
            return "";
        }
    }

    function tokenidcall(string memory name) external view returns(uint){
        return domainid[name];
    }

    function subcheck(string memory _strings) private pure returns(bool){
        strings.slice memory slicee = _strings.toSlice();
        strings.slice memory delim = ".".toSlice();
        uint x = slicee.count(delim);
        if(x == 0){
            return true;
        }else{
            return false;
        }
    }

    function spacecheck(string memory _strings) private pure returns(bool){
        strings.slice memory slicee = _strings.toSlice();
        strings.slice memory delim = " ".toSlice();
        uint x = slicee.count(delim);
        if(x == 0){
            return true;
        }else{
            return false;
        }
    }

    function bigspacecheck(string memory _strings) private pure returns(bool){
        strings.slice memory slicee = _strings.toSlice();
        strings.slice memory delim = "\u3000".toSlice();
        uint x = slicee.count(delim);
        if(x == 0){
            return true;
        }else{
            return false;
        }
    }

    //運営者のみ宣伝用NFTを無料で発行可能
    function whitelistmint(string memory name) external {
        require(stuffaccount == msg.sender);
        require(subcheck(name) == true);
        require(spacecheck(name) == true);
        require(bigspacecheck(name) == true);
        if(domainid[name] == 0){//未登録
           //getname(name,msg.sender);
            uint256 tokenId = latestTokenId;
            _mint(msg.sender, tokenId);
            domainid[name] = tokenId;
            reverseDomain[tokenId] = name;
            expiries[tokenId] = block.timestamp + 3650 days;//10年
            latestTokenId++;
            emit DomainGet(name,msg.sender,expiries[tokenId]);
        }else if(domainid[name] != 0 && available(domainid[name])==true){
           //Regetname(name,msg.sender);
           uint x = domainid[name];
            _burn(x);
            _mint(msg.sender, x);
            expiries[x] = block.timestamp + 3650 days;//10年
            emit DomainGet(name,msg.sender,expiries[x]);
        }
    }

    function PriceChange(uint p7,uint p6,uint p5,uint p4,uint p3,uint p2,uint p1) external {
        require(stuffaccount == msg.sender);
        price7 = p7;
        price6 = p6;
        price5 = p5;
        price4 = p4;
        price3 = p3;
        price2 = p2;
        price1 = p1;
    }

    function TimerChange(uint ta,uint t6,uint t5,uint t4,uint t3,uint t2,uint t1)external {
        require(stuffaccount == msg.sender);
        timerall = ta;
        timer6 = t6;
        timer5 = t5;
        timer4 = t4;
        timer3 = t3;
        timer2 = t2;
        timer1 = t1;
    }

    function AccountChange(address withdraw,address stuff)external onlyOwner{
       stuffaccount = stuff;
       withdrawaccount = withdraw;
    }


    function withdraw() external {
        require(withdrawaccount == msg.sender);
        payable(msg.sender).transfer(address(this).balance);
    }

    
}
