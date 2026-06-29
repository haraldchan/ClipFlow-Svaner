// globals
let socket = null;
let currentData = {};
const identifier = '3ed542123e774d45203ff60175cb614e'; //MD5 hash: ProfileModifyNextLocal
const ports = ['8010', '90', '17181', '17182'];
const connStatusClasses = [
	'status-connecting',
	'status-disconnected',
	'status-connected',
];


// init
function onLaunch() {
	for (const code in nationalityAreas) {
		createOption(regionList, code, nationalityAreas[code]);
	}

	for (const [code, idTypeName] of cardTypes) {
		createOption(idType, idTypeName, code);
	}

	for (const port of ports) {
		textContent = '';
		switch (port) {
			case '8010':
				textContent = '雄帝:8010';
				break;
			case '90':
				textContent = '文通:90';
			default:
				textContent = `科蓝:${port}`;
				break;
		}

		createOption(portSelect, textContent, port);
	}

	connectOrDisconnect();
}