var Web3 = require('web3');    // 응용에서 web3 불러오기
var web3 = new Web3();        
// web3와 실행한 사설 이더리움 넥트워크를 연결
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

const contractAddress = '0xd10c5a8ac4ba3b35d9deb25e18ef1c1cff60361a';	// 컨트랙트 주소
const smartContract = web3.eth.contract(abi).at(contractAddress);		// 컨트랙트 연결

function init() {
  // 첫번째 계정으로 주소 설정
  web3.eth.getAccounts(function(err,r){ 
	document.getElementById('account').value = r[0]; 
  });
  document.getElementById('owner').innerHTML = smartContract.getOwner(); // 댑 개발자 주소 출력
}

function showList() {	// 거래 목록 출력
  const table = document.getElementById('table1');
  const rowCount = table.rows.length;
  for (let i = 0; i < rowCount; i++) {	// 테이블 초기화
	table.deleteRow(0);
  }
  
  smartContract.getTotal(function(e,r){	// 컨트랙트의 함수 호출해 거래 목록 출력
	const length = r;
	document.getElementById('procount').value = length;
		
	const row = table.insertRow();
	const cell1 = row.insertCell(0);
	const cell2 = row.insertCell(1);
	const cell3 = row.insertCell(2);
	const cell4 = row.insertCell(3);
	const cell5 = row.insertCell(4);
	const cell6 = row.insertCell(5);
	const cell7 = row.insertCell(6);
	cell1.innerHTML = "상품 번호";
	cell1.style.width = '10%';
	cell2.innerHTML = "브랜드 이름";
	cell3.innerHTML = "년도";
	cell4.innerHTML = "가격";
	cell5.innerHTML = "판매자 연락처";
	cell6.innerHTML = "거래 상태";
	cell7.style.width = '10%';
	cell7.innerHTML = "사진";

	for (let i = 0; i < length; i++) {
	  const product = smartContract.getProduct(i);
	  const toString = product.toString();
	  const strArray = toString.split(',');

	  const row = table.insertRow();
	  const cell1 = row.insertCell(0);
	  const cell2 = row.insertCell(1);
	  const cell3 = row.insertCell(2);
	  const cell4 = row.insertCell(3);
	  const cell5 = row.insertCell(4);
	  const cell6 = row.insertCell(5);
	  const cell7 = row.insertCell(6);
	  cell1.innerHTML = strArray[0];
	  cell1.style.width = '10%';
	  cell2.innerHTML = strArray[1];
	  cell3.innerHTML = strArray[2];
	  cell4.innerHTML = strArray[3];
	  cell5.innerHTML = strArray[4]; 
	  var str = { '0' : '판매 중', '1' : '배송 대기', '2' : '배송 완료', '3' : '거래 완료' };
	  cell6.innerHTML = str[strArray[5]];
	  cell7.style.width = '10%';
	  cell7.innerHTML = "<img src=\"uploads/" + i +".jpg\" width=\"75px\" height=\"75px\">";
	}
  });
}

function addProduct() {	// 판매 물품 등록
  const proname = document.getElementById('proname').value;
  const prodate = document.getElementById('prodate').value;
  const proprice = document.getElementById('proprice').value;
  const protel = document.getElementById('protel').value;
  const account = document.getElementById('account').value;
  smartContract.addProduct(
    proname,
    prodate,
    proprice,
	protel,
    { from: account, gas: 3000000 },
    (err, result) => {
      if (!err) alert('물품이 성공적으로 등록되었습니다.\n' + result);
    }
  );
  showList();
}

function buyProduct() {	// 물품 구매
  const pronum = document.getElementById('pronum').value;
  const payprice = document.getElementById('payprice').value;
  const account = document.getElementById('account').value;
  smartContract.buyProduct(
    pronum,
    { from: account, gas: 3000000, value: payprice * 1000000000000000 },
    (err, result) => {
      var msg = smartContract.getMessage();
      if (!err) alert(msg);
    }
  );
  showList();
}

function sendProduct() { // 물품 배송
  const pronum = document.getElementById('pronum').value;
  const account = document.getElementById('account').value;
  smartContract.sendProduct(
    pronum,
    { from: account, gas: 3000000 },
    (err, result) => {
      var msg = smartContract.getMessage();
      if (!err) alert(msg);
    }
  );
  showList();
}

function confirmProduct() { // 구매 확정
  const pronum = document.getElementById('pronum').value;
  const account = document.getElementById('account').value;
  smartContract.confirmProduct(
    pronum,
    { from: account, gas: 3000000 },
    (err, result) => {
      var msg = smartContract.getMessage();
      if (!err) alert(msg);
    }
  );
  showList();
}

function refund() { // 환불
  const pronum = document.getElementById('pronum').value;
  const account = document.getElementById('account').value;
  smartContract.refund(
    pronum,
    { from: account, gas: 3000000 },
    (err, result) => {
      var msg = smartContract.getMessage();
      if (!err) alert(msg);
    }
  );
  showList();
}

$(function() {
  init();
  showList();
});
