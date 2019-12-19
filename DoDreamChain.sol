pragma solidity ^0.4.24;

import "./DoDreamChainBase.sol";


/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

    /**
     * Returns whether the target address is a contract
     * dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param addr address to check
     * @return whether the target address is a contract
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}

/**
 * @title DoDreamChain
 */
contract DoDreamChain is DoDreamChainBase {

  event TransferedToDRMDapp(
        address indexed owner,
        address indexed spender,
        address indexed to, uint256 value, DRMReceiver.DRMReceiveType receiveType);

  string public constant name = "DoDreamChain";
  string public constant symbol = "DRM";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 250 * 1000 * 1000 * (10 ** uint256(decimals)); // 250,000,000 DRM

  /**
   * @dev Constructor 생성자에게 DRM토큰을 보냅니다.
   */
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }

  function drmTransfer(address _to, uint256 _value) public returns (bool) {
      return drmTransfer(_to, _value);
  }

  function drmTransferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      return drmTransferFrom(_from, _to, _value);
  }

  function postTransfer(address owner, address spender, address to, uint256 value,
   DRMReceiver.DRMReceiveType receiveType) internal returns (bool) {
        if (AddressUtils.isContract(to)) {
            bool callOk = address(to).call(bytes4(keccak256("onDRMReceived(address,address,uint256,uint8)")), owner, spender, value, receiveType);
            if (callOk) {
                emit TransferedToDRMDapp(owner, spender, to, value, receiveType);
            }
        }

        return true;
    }

  function drmMintTo(address to, uint256 amount, string note) public onlyOwner returns (bool ret) {
        ret = drmMintTo(to, amount, note);
        postTransfer(0x0, msg.sender, to, amount, DRMReceiver.DRMReceiveType.DRM_MINT);
    }

    function drmBurnFrom(address from, uint256 value, string note) public onlyOwner returns (bool ret) {
        ret = drmBurnFrom(from, value, note);
        postTransfer(0x0, msg.sender, from, value, DRMReceiver.DRMReceiveType.DRM_BURN);
        return ret;
    }

}

/**
 * @title DRM Receiver
 */
contract DRMReceiver {
    enum DRMReceiveType { DRM_TRANSFER, DRM_MINT, DRM_BURN }
    function onDRMReceived(address owner, address spender, uint256 value, DRMReceiveType receiveType) public returns (bool);
}


