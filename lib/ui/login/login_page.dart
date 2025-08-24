import 'package:better/domain/app_colors.dart';
import 'package:better/domain/ui_heloper.dart';
import 'package:flutter/material.dart';
import "package:better/ui/custom_widgets/oblong_button.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ReownAppKit? _appKit;
  ReownAppKitModal? _appKitModal;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWalletConnect();
  }

  Future<void> _initializeWalletConnect() async {
    final projectId = dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';
    try {
      _appKit = ReownAppKit(
        core: ReownCore(projectId: projectId, logLevel: LogLevel.error),
        metadata: PairingMetadata(
          name: 'Better App',
          description: 'Music streaming app with Web3 integration',
          url: 'https://better-app.com',
          icons: ['https://better-app.com/assets/Logo/walletconnect.svg'],
          redirect: Redirect(
            native: 'better://',
            universal: 'https://better-app.com',
          ),
        ),
      );

      // Initialize the modal with proper configuration
      _appKitModal = ReownAppKitModal(
        context: context,
        appKit: _appKit!,
        featuresConfig: FeaturesConfig(
          socials: [
            AppKitSocialOption.Google,
            AppKitSocialOption.Apple,
            AppKitSocialOption.Discord,
            AppKitSocialOption.X,
            AppKitSocialOption.Email,
          ],
          showMainWallets: true,
        ),
        // Add required namespaces for EVM chains
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: ['eip155:1'], // Ethereum mainnet
            methods: [
              'eth_sendTransaction',
              'personal_sign',
              'eth_signTypedData',
              'eth_signTypedData_v4',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
        // Add optional namespaces for additional chains
        optionalNamespaces: {
          'eip155': RequiredNamespace(
            chains: [
              'eip155:137', // Polygon
              'eip155:10', // Optimism
              'eip155:42161', // Arbitrum
            ],
            methods: [
              'eth_sendTransaction',
              'personal_sign',
              'eth_signTypedData',
              'eth_signTypedData_v4',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );

      // Set up event listeners
      _appKitModal!.onModalConnect.subscribe(_onWalletConnect);
      _appKitModal!.onModalDisconnect.subscribe(_onWalletDisconnect);
      _appKitModal!.onModalError.subscribe(_onWalletError);

      // Initialize the modal
      await _appKitModal!.init();

      debugPrint('WalletConnect initialized successfully');
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Failed to initialize WalletConnect: $e');
      setState(() {
        _isInitialized = false;
      });
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize wallet connection: $e')),
        );
      }
    }
  }

  void _onWalletConnect(ModalConnect? event) {
    debugPrint('Wallet connected successfully!');
    debugPrint('Session: ${_appKitModal?.session}');

    // Navigate to your main app or show success
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Wallet connected successfully!')));

    // Navigate to next screen
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  void _onWalletDisconnect(ModalDisconnect? event) {
    debugPrint('Wallet disconnected');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Wallet disconnected')));
  }

  void _onWalletError(ModalError? event) {
    debugPrint('Wallet error: ${event?.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(event?.message ?? 'Connection error')),
    );
  }

  Future<void> _connectWallet() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet connection is still initializing...')),
      );
      return;
    }

    try {
      if (_appKitModal!.isConnected) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Wallet already connected!')));
        return;
      }

      debugPrint('Opening wallet connection modal...');

      await _appKitModal!.openModalView();

      debugPrint('Modal opened successfully');
    } catch (e) {
      debugPrint('Error opening wallet modal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: ${e.toString()}')),
      );
    }
  }

  void _handleGoogleLogin() {
    // Implement Google OAuth login here
    debugPrint('Google login tapped');
    // You can also open WalletConnect with Google social login
    _connectWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Stack(
        children: [
          Image.asset("assets/images/poster.png"),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.blackColor.withOpacity(0.3),
                  AppColors.blackColor,
                ],
              ),
            ),
          ),
          bottomloginUI(),
        ],
      ),
    );
  }

  Widget bottomloginUI() => Container(
    padding: EdgeInsets.only(bottom: 50),
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/Logo/spotify-white-icon.svg",
          width: 50,
          height: 50,
        ),
        msPacer(),
        Text(
          "Millions of songs. \nFree on Spotify.",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        msPacer(),
        msPacer(),
        msPacer(),
        OblongButton(
          mIconPath: "assets/Logo/google-icon.svg",
          text: "Continue with Google",
          bgColor: const Color(0xFF1F1F1F),
          textColor: Colors.white,
          borderColor: const Color(0xFF3C4043),
          mWidth: 280,
          mHeight: 48,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          iconSize: 18,
          onTap: _handleGoogleLogin,
        ),
        msPacer(),
        OblongButton(
          mIconPath: _isInitialized ? "assets/Logo/walletconnect.svg" : null,
          text: _isInitialized ? "Continue with Wallet" : "",
          bgColor: const Color(0xFF1F1F1F),
          textColor: Colors.white,
          borderColor: const Color(0xFF3C4043),
          mWidth: 280,
          mHeight: 48,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          iconSize: 18,
          onTap: _isInitialized ? _connectWallet : null,
          isLoading: !_isInitialized,
        ),

        msPacer(),
        TextButton(
          onPressed: () {
            // Handle regular login
            debugPrint('Login tapped');
          },
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // Show connection status
        if (_appKitModal?.isConnected == true)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                Text(
                  'Wallet Connected Successfully!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await _appKitModal!.disconnect();
                  },
                  child: Text(
                    'Disconnect',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  @override
  void dispose() {
    _appKitModal?.onModalConnect.unsubscribe(_onWalletConnect);
    _appKitModal?.onModalDisconnect.unsubscribe(_onWalletDisconnect);
    _appKitModal?.onModalError.unsubscribe(_onWalletError);
    super.dispose();
  }
}
