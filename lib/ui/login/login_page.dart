import 'package:bitbet/domain/app_colors.dart';
import 'package:bitbet/domain/ui_heloper.dart';
import 'package:bitbet/domain/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:bitbet/ui/custom_widgets/oblong_button.dart';
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
      // Create ReownAppKit instance
      _appKit = ReownAppKit(
        core: ReownCore(projectId: projectId, logLevel: LogLevel.error),
        metadata: PairingMetadata(
          name: 'BitBet App',
          description: 'Sports betting app with Web3 integration',
          url: 'https://bitbet-app.com',
          icons: ['https://bitbet-app.com/assets/Logo/walletconnect.svg'],
          redirect: Redirect(
            native: 'bitbet://',
            universal: 'https://bitbet-app.com',
          ),
        ),
      );

      // Check for existing session before full initialization
      if (_appKit!.core.pairing.getPairings().isNotEmpty) {
        debugPrint('Existing WalletConnect session found, checking connection');
        _appKitModal = ReownAppKitModal(context: context, appKit: _appKit!);
        await _appKitModal!.init();
        if (_appKitModal!.isConnected) {
          debugPrint('Already connected, navigating to home');
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
          return;
        }
      }

      // Full initialization if no existing session
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
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: ['eip155:1'],
            methods: [
              'eth_sendTransaction',
              'personal_sign',
              'eth_signTypedData',
              'eth_signTypedData_v4',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
        optionalNamespaces: {
          'eip155': RequiredNamespace(
            chains: ['eip155:137', 'eip155:10', 'eip155:42161'],
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

      _appKitModal!.onModalConnect.subscribe(_onWalletConnect);
      _appKitModal!.onModalDisconnect.subscribe(_onWalletDisconnect);
      _appKitModal!.onModalError.subscribe(_onWalletError);

      await _appKitModal!.init();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize wallet connection: $e')),
        );
      }
    }
  }

  void _onWalletConnect(ModalConnect? event) {
    debugPrint('Wallet connected successfully! Event: $event');
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      debugPrint('Widget not mounted, cannot navigate to home');
    }
  }

  void _onWalletDisconnect(ModalDisconnect? event) {
    debugPrint('Wallet disconnected: $event');
  }

  void _onWalletError(ModalError? event) {
    debugPrint('Wallet error: ${event?.message}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(event?.message ?? 'Connection error')),
      );
    }
  }

  Future<void> _connectWallet() async {
    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet connection is still initializing...'),
          ),
        );
      }
      return;
    }

    try {
      if (_appKitModal!.isConnected) {
        debugPrint('Already connected, navigating to home');
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
        return;
      }
      debugPrint('Opening WalletConnect modal');
      await _appKitModal!.openModalView();
      if (_appKitModal!.isConnected && mounted) {
        debugPrint('Connection confirmed after modal, navigating to home');
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: ${e.toString()}')),
        );
      }
    }
  }

  void _handleGoogleLogin() {
    debugPrint('Google login tapped');
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
    padding: const EdgeInsets.only(bottom: 50),
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/svg/games.svg",
          width: 50,
          height: 50,
          color: Colors.white,
        ),
        msPacer(),
        const Text(
          "bitbet odds. \nSmarter betting.",
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
            debugPrint('Login tapped');
          },
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
