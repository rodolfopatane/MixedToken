// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

struct IndexedTokenStruct {
    address token;
    uint256 amount;
}

contract MixedToken is ERC20, Ownable {
    mapping(address => uint256) private _indexedTokensFunds;
    address[] private _indexedTokens;

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    constructor(uint256 _totalSupply) ERC20("MixedToken", "MT") {
        _mint(msg.sender, _totalSupply); /* represent 100% of another tokens */
    }

    function indexToken(address _newToken, uint256 amount) public onlyOwner {
        require(
            ERC20(_newToken).balanceOf(msg.sender) > 0 &&
                ERC20(_newToken).balanceOf(msg.sender) >= amount,
            "You dont't have balance"
        );

        if (_indexedTokensFunds[_newToken] <= 0) {
            _indexedTokens.push(_newToken);
        }

        ERC20(_newToken).transferFrom(msg.sender, address(this), amount);
        _indexedTokensFunds[_newToken] = ERC20(_newToken).balanceOf(
            address(this)
        );
    }

    function getIndexedTokensFunds()
        public
        view
        returns (IndexedTokenStruct[] memory)
    {
        uint256 size = _indexedTokens.length;
        require(size > 0, "No tokens indexed");
        IndexedTokenStruct[] memory indexTokensArray = new IndexedTokenStruct[](
            size
        );

        for (uint256 i = 0; i < size; i++) {
            IndexedTokenStruct memory indexTokens = IndexedTokenStruct(
                _indexedTokens[i],
                _indexedTokensFunds[_indexedTokens[i]]
            );
            indexTokensArray[i] = indexTokens;
        }
        return indexTokensArray;
    }

    function getIndexedTokens() public view returns (address[] memory) {
        return _indexedTokens;
    }
}
