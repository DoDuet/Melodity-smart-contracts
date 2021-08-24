// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Melodity is ERC20 {
    constructor() ERC20("Melodity", "MELD") {
        // max supply 1 billion MELD

        _mint(payable(address(0xD270299A4a2Ab82A5a5352dEfE748e2a5732e738)), 350000000 * 1 ether);   // ico address - 350 million
        _mint(payable(address(0x01Af10f1343C05855955418bb99302A6CF71aCB8)), 250000000 * 1 ether);   // company multisig - 250 million
        _mint(payable(address(0x8224a83d5bb631316C4491dd8AC3C4300bE5F0C4)), 200000000 * 1 ether);   // pre ico investment - 200 million
        _mint(payable(address(0x7C44bEfc22111e868b3a0B1bbF30Dd48F99682b3)), 100000000 * 1 ether);   // bridge wallet - 100 million
        _mint(payable(address(0xFC5dA6A95E0C2C2C23b8C0c387CDd3Af7E56FCC0)), 24000000 * 1 ether);    // ebalo
        _mint(payable(address(0xAae81A528f3acca9607B6607D3d2143A80535a24)), 24189556 * 1 ether);    // marco
        _mint(payable(address(0x618E9F7bbbeF323019eEf457f3b94E9E7943633A)), 14000000 * 1 ether);    // rolen
        _mint(payable(address(0x3198c11724024C9cE7F81816E6E6B69580fe5585)), 12000000 * 1 ether);    // will
        
        // Donations
        _mint(payable(address(0xB591244190BF1bE60eA0787C3644cfE12FDc593E)), 105263157894737000000000);
        _mint(payable(address(0x1513A2c5ebb821080EF7F34DA0EeD06Efb3e5d77)), 131578947368421000000000);
        _mint(payable(address(0xAC363fC2776368181C83ba48C1e839221D5a9b60)), 105263157894737000000000);
        _mint(payable(address(0x94757426b8A26E87a9AB95567532c32411940f9D)), 78947368421052600000000);
        _mint(payable(address(0x16CB5531304F344565998bFD1b454A9890042Ed2)), 52631578947368400000000);
        _mint(payable(address(0x99A4Bf11eAbdd449398e0eCc6F6f91f993E51011)), 78947368421052600000000);
        _mint(payable(address(0xf504df7A15Af507319068A25ba5D08529197c525)), 52631578947368400000000);
        _mint(payable(address(0x6dC6E1Db441c606Ad8557d113e8101fCe10fB44e)), 52631578947368400000000);
        _mint(payable(address(0xCF29334DC2a09C42430b752978cCE7BD8cbC8112)), 78947368421052600000000);
        _mint(payable(address(0xe64352760D6D80e0002f0c0FfE1353fb905bC99C)), 52631578947368400000000);
        _mint(payable(address(0x1c21DaC598293e807772fA24553b27b5BEA7BA0D)), 52631578947368400000000);
        _mint(payable(address(0x32dc4D58B923c831F7E6B9533996e714E09FD911)), 78947368421052600000000);
        _mint(payable(address(0x2Be310D9bC184a65c9522E790E894A10eA347539)), 78947368421052600000000);
        _mint(payable(address(0x77eFaE135472DcFbfc50e846c0dBc020Ae6c1c56)), 25000 * 1 ether);
        _mint(payable(address(0x9352e3E8f54310742414350ae10F7E908e39dc3F)), 10000 * 1 ether);
        _mint(payable(address(0xD96412a2F99F406c0973C8BD1ed6C89804A47B01)), 4444 * 1 ether);
        _mint(payable(address(0xA47D086cbAD31106250749727Ac50C6A604c00D9)), 50000 * 1 ether);
        _mint(payable(address(0x880A21A432240692bc5A3985a7DeD30095d5B9Ec)), 30000 * 1 ether);
        _mint(payable(address(0xf534FA9B706973F50Ae110593AeF6555F22E545b)), 11000 * 1 ether);
        _mint(payable(address(0xc44847983F54e4085C80B3CAa0dA208d8279eeFd)), 15000 * 1 ether);
        _mint(payable(address(0x5f5d8Db4028B5818C183822f9eD32B44a564cCF4)), 10000 * 1 ether);
        _mint(payable(address(0x117cC4B43B2158ECAD9D95731B216B77fBb6A24f)), 10000 * 1 ether);
        _mint(payable(address(0xe99dB2Fc7b25f9f61a288008e0eb69dEdA1d270f)), 25000 * 1 ether);
        _mint(payable(address(0x382be12c3632Fb45347f1126361Ab94dbd88C5E1)), 100000 * 1 ether);
        _mint(payable(address(0xc0F6Ef6524a46CFfCdbb5821533197CF75bdb081)), 10000 * 1 ether);
        _mint(payable(address(0xf2C5C101db1C5d21e366e896Ee8fe74145Ca756B)), 50000 * 1 ether);
        _mint(payable(address(0x61a437415968F7E480E2Dc50136a81eC88673af3)), 50000 * 1 ether);
        _mint(payable(address(0x4F9AC043E21B1D843Ffeb6A2e7D306b99A70698A)), 5000 * 1 ether);
        _mint(payable(address(0x88E79Ab6E018297bF0f4Dc353f19Ed78446785E8)), 15000 * 1 ether);
        _mint(payable(address(0x8122ce1A449b7740e5Ea164052a27dCBA553891B)), 100000 * 1 ether);
        _mint(payable(address(0x05283Fc4b16184ea13C564E862dc26EC7bC4b4C5)), 30000 * 1 ether);
        _mint(payable(address(0x27a548F27928a0e755AA1DB3776d074A628067cE)), 15000 * 1 ether);
        _mint(payable(address(0x5704FA8922cafCf87E5B4beEdd87CC88086D4463)), 50000 * 1 ether);
        _mint(payable(address(0x9FD41557722A6dACb74a43678200348095183E97)), 15000 * 1 ether);
        _mint(payable(address(0x8519407F477BaA160c9d1814aE81EA55a43D8AC9)), 5000 * 1 ether);
        _mint(payable(address(0xEa078F2C5b3747aBa3B496f1E88AE6CE29018f87)), 100000 * 1 ether);
        _mint(payable(address(0xF00c2F1Ee2Ffc099cF4d65f2A93fF08E61E7B7CE)), 15000 * 1 ether);
        _mint(payable(address(0x7FF86d7cF8a88B1f4bb9Ceb8be29C8448DEAd6c1)), 40000 * 1 ether);
        _mint(payable(address(0xB01D0b3DB469BeF34c1e09Fe235814EDecEa4937)), 20000 * 1 ether);
        _mint(payable(address(0x01ADD5D56e779183F3B52351E2145D1C4Ef4f896)), 10000000 * 1 ether);
        _mint(payable(address(0x6EF4651B5fCc6531C8f25eB1bd9af86923Cb86cb)), 250000 * 1 ether);
        _mint(payable(address(0x0C25906Ec039F2073E585D26991AE613544a26E0)), 150000 * 1 ether);
        _mint(payable(address(0x15939079E39A960D8077d6fEbb92664252a2b7B8)), 150000 * 1 ether);
        _mint(payable(address(0x485732157D0aa400081251D53c390a5921bFF0A8)), 150000 * 1 ether);
        _mint(payable(address(0xD2fb1d3cc0bbE8A29bC391Ca435e544d781EA5a7)), 150000 * 1 ether);
        _mint(payable(address(0x319B8D649890490Ab22C9cE8ae7ea2e0Cc61a3f8)), 150000 * 1 ether);
        _mint(payable(address(0x1b314dcA8Cc5BcA109dFb80bd91f647A3cD62f28)), 12000000 * 1 ether);
        _mint(payable(address(0x435298a529750E8A65bF2589D3F41c59bCB3a274)), 100000 * 1 ether);
        _mint(payable(address(0x891539D631d4ed5E401aFa54Cc4b3197BEd73Aae)), 100000 * 1 ether);
        _mint(payable(address(0xB40D8A30E5215DA89490D0209FEc3e6C9008fd80)), 100000 * 1 ether);
        _mint(payable(address(0x91A6FfB93Ae9b7F4009978c92259b51DB1814f75)), 100000 * 1 ether);
        _mint(payable(address(0xEe72d0857201bdc932B256A165b9c4e0C8ECF055)), 425000 * 1 ether);
        _mint(payable(address(0x30817A8e6Dc225B89c5670BCc5a9a66f987b7F04)), 100000 * 1 ether);
        _mint(payable(address(0x382be12c3632Fb45347f1126361Ab94dbd88C5E1)), 75000 * 1 ether);
    }
}