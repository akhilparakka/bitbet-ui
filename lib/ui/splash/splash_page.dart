import 'dart:async';
import 'package:bitbet/domain/app_colors.dart';
import 'package:bitbet/domain/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reown_appkit/reown_appkit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double width = 10;
  double height = 10;
  ReownAppKit? _appKit;
  ReownAppKitModal? _appKitModal;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWalletConnect();
    animate();
  }

  Future<void> _initializeWalletConnect() async {
    final projectId = dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';
    try {
      _appKit = ReownAppKit(
        core: ReownCore(projectId: projectId, logLevel: LogLevel.error),
        metadata: PairingMetadata(
          name: 'bitbet App',
          description: 'Music streaming app with Web3 integration',
          url: 'https://bitbet-app.com',
          icons: ['https://bitbet-app.com/assets/Logo/walletconnect.svg'],
          redirect: Redirect(
            native: 'bitbet://',
            universal: 'https://bitbet-app.com',
          ),
        ),
      );

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
        // Check connection status after initialization
        _checkConnection();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize wallet connection: $e')),
        );
        // Navigate to LoginPage on initialization failure
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        });
      }
    }
  }

  void _onWalletConnect(ModalConnect? event) {
    debugPrint('Wallet connected successfully! Event: $event');
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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

  void _checkConnection() async {
    // Ensure minimum splash duration
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        if (!_isInitialized) {
          // Not initialized, navigate to LoginPage
          debugPrint('Not initialized, navigating to login');
          Navigator.pushReplacementNamed(context, AppRoutes.login);
          return;
        }
        try {
          if (_appKitModal!.isConnected) {
            // Already connected, navigate to HomePage
            debugPrint('Already connected in SplashPage, navigating to home');
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else {
            // Not connected, navigate to LoginPage
            debugPrint('Not connected in SplashPage, navigating to login');
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        } catch (e) {
          debugPrint('Connection check error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connection check error: ${e.toString()}'),
              ),
            );
            // Navigate to LoginPage on error
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        }
      }
    });
  }

  void animate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        width = 80;
        height = 70;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              width: width,
              height: height,
              child: SvgPicture.asset(
                "assets/Logo/spotify-icon.svg",
                width: width,
                height: height,
              ),
            ),
          ),
          if (!_isInitialized)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 32.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _appKitModal?.onModalConnect.unsubscribe(_onWalletConnect);
    _appKitModal?.onModalDisconnect.unsubscribe(_onWalletDisconnect);
    _appKitModal?.onModalError.unsubscribe(_onWalletError);
    super.dispose();
  }
}
