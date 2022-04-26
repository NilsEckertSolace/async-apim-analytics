import path from 'path';
import s from 'shelljs';
import request from 'supertest';
import server from '../../dist/server';
import { logger } from '../lib/test-helper';

const scriptName: string = path.basename(__filename);
const scriptDir: string = path.dirname(__filename);

const connectorServerDirectory = `${scriptDir}/../resources/apim-connector`;

export async function mochaGlobalSetup() {

  logger.log(scriptName, 'Setup test environment ...');

  // create and start local connector
  const code = s.exec(`bash ${connectorServerDirectory}/setup.sh 2>&1`, { silent: false }).code
  if (code != 0) {
    logger.log(scriptName, 'Setup of API Management Connector failed');
    process.exit(1);
  }

  // start analytics server
  await request(server).get('/').expect(200).catch(() => {
    logger.log(scriptName, 'Start of API Management Analytics Server failed');
    process.exit(1);
  });

  logger.log(scriptName, 'Setup finished');
}

export async function mochaGlobalTeardown() {

  logger.log(scriptName, 'Teardown test environment ...');

  // stop and remove local connector 
  const code = s.exec(`bash ${connectorServerDirectory}/teardown.sh 2>&1`, { silent: false }).code
  if (code != 0) {
    logger.log(scriptName, 'Teardown of API Management Connector failed');
    process.exit(1);
  }

  logger.log(scriptName, 'Teardown finished');
}
