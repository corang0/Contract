pragma solidity ^0.4.24;

contract ProductContract {
    uint8 total;            // 총 제품의 수
    address public owner;   // 댑 개발자
    // 구매 가능, 구매 중(이더 봉인), 물품 전송됨, 거래 완료
    enum State { Created, Locked, Sent, Complete }
    uint unit = 1000000000000000;   // 거래 단위 (finney)
    struct myStruct {   // 자전거 거래 정보 저장용 구조체
        string  brandName;  // 브랜드 이름
        string  date;       // 년도
        uint    price;      // 가격
        string  tel;        // 판매자 연락처
        State   state;      // 거래 상태
        address seller;     // 물건 판매자
        address buyer;      // 물건 구매자
    }
    string public message;  // 출력용 메시지
    myStruct[] public products; // 상품 리스트
    
    constructor() public { owner = msg.sender; }    // 댑 개발자 주소 설정
    modifier Owned { require(msg.sender == owner);  _; }    // 댑 개발자 여부확인
    function getOwner() public view returns(address) { return owner; }  // 댑 개발자 주소 반환
    function getMessage() public view returns(string memory) { return message; } // 출력용 메시지 반환

    /* 사용자가 입력한 제품을 등록 */
    function addProduct (string memory _brandName, string memory _date, uint _price, string memory _tel) public {
        products.push(myStruct(_brandName, _date, _price, _tel, State.Created, msg.sender, address(0)));
        total++;
        message = "Item registered.";
    }

    /* 번호에 해당하는 제품의 이름을 리턴 */
    function getProduct(uint _idx) public view returns (uint, string memory, string memory, uint, string memory, State) {
        return (_idx, products[_idx].brandName, products[_idx].date, products[_idx].price, products[_idx].tel, products[_idx].state);
    }

    /* 제품 등록의 수를 리턴 */
    function getTotal() public view returns(uint8) {
        return total;
    }
    
    /* 현재 컨트랙트 잔액 */
    function getBalance() public view returns (uint) { 
       return address(this).balance;
    }
    
    /* 번호에 해당하는 제품을 구매 */
    function buyProduct(uint _idx) payable public{
        if (products[_idx].state == State.Created){   // 구매 가능한지 확인
            if (msg.value==products[_idx].price*unit){     // 금액 같을시 송금 처리
                products[_idx].buyer= msg.sender;
                products[_idx].state= State.Locked;
                message = "Item purchased.";
            }
            else if (msg.value<products[_idx].price*unit){ // 금액 미달시 송금 취소
                if (!products[_idx].buyer.send(msg.value)){
                    revert();
                }
                message = "Not enough money.";
            }
            else {                                    // 금액 초과시 차액 지급
                products[_idx].buyer= msg.sender;
                products[_idx].state= State.Locked;
                if (!products[_idx].buyer.send(msg.value - products[_idx].price*unit)){
                    revert();
                }
                message = "Returns change.";
            }
        }
        else {  // 구매 불가능한 상품(송금 취소)
            if (!products[_idx].buyer.send(msg.value)){
                revert();
            }
            message = "Item is not available.";
        }
    }
    
    /* 판매자가 물건 배송 */
    function sendProduct(uint _idx) public { // 판매자 주소와 일치하는지 확인 후 물건 배송
        if (msg.sender==products[_idx].seller && products[_idx].state==State.Locked){
            products[_idx].state = State.Sent;
            message = "Item sent.";
        }  
    }
    
    /* 구매자가 돈 봉인 해제 */
    function confirmProduct(uint _idx) public {
        if (msg.sender == products[_idx].buyer){ // 구매자 주소와 일치하는지 확인 후 돈 봉인 해제
            if (!products[_idx].seller.send(products[_idx].price*unit/100*99)){  // 구매자에게 99% 송금
                revert();
            }
            else{
               products[_idx].state = State.Complete;
               message = "Process finished.";
            }
            
            if (!owner.send(products[_idx].price*unit/100)){ // 댑 개발자에게 1% 수수료 송금
                revert();
            }
        }  
    }
    
    /* 물건 배송 전 환불 */
    function refund(uint _idx) public {
        if (msg.sender==products[_idx].buyer ){ // 구매자 주소와 일치하는지 확인 후 환불
            if (products[_idx].state==State.Locked){
                if (!products[_idx].buyer.send(products[_idx].price*unit)){
                    revert();
                }
                else {  // 구매 가능한 상태로 초기화
                    products[_idx].state=State.Created;
                    products[_idx].buyer=address(0);
                }
            }   
        }
    }
    
    /* 거래내용 정리 후 댑 파괴 */
    function kill() public Owned {  // 댑 개발자 여부확인
        for (uint i = 0; i < total; i++) {  // 모든 거래 상태 조회
            if (products[i].state==State.Locked){   // 구매로 전송된 돈 환불
                if (!products[i].buyer.send(products[i].price*unit)){
                    revert();
                }
            }
            if (products[i].state==State.Sent){     // 봉인된 돈 지급
                if (!products[i].seller.send(products[i].price*unit/100*99)){
                    revert();
                }
                
                if (!owner.send(products[i].price*unit/100)){
                    revert();
                }
            }
        }
        
        selfdestruct(owner);    // 댑 파괴
    }
}