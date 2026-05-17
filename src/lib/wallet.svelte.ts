import { SuiGrpcClient } from '@mysten/sui/grpc';

export const suiClient = new SuiGrpcClient({
  network: 'testnet',
  baseUrl: 'https://fullnode.testnet.sui.io:443'
});

class WalletState {
  connectedWallet: any = $state.raw(null);
  connectedAccount: any = $state.raw(null);
  suiBalance: string = $state("0");
}

export const walletStore = new WalletState();
