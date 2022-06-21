// ignore_for_file: non_constant_identifier_names

part of azkagram;

class HexaWalletPage extends StatefulWidget {
  const HexaWalletPage({Key? key, required this.box}) : super(key: key);
  final Box box;
  @override
  State<HexaWalletPage> createState() => _HexaWalletPageState();
}

class _HexaWalletPageState extends State<HexaWalletPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('hexaminate').listenable(),
        builder: (ctx, box, widget) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late Widget widget_app = const Center(
                child: Text("Hello World"),
              );
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
                  child: widget_app,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HexaBlogPage extends StatefulWidget {
  HexaBlogPage({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  State<HexaBlogPage> createState() => _HexaBlogPageState();
}

class _HexaBlogPageState extends State<HexaBlogPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('hexaminate').listenable(),
        builder: (ctx, box, widget) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late Widget widget_app = const Center(
                child: Text("Hello World"),
              );
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
                  child: widget_app,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HexaShopPage extends StatefulWidget {
  HexaShopPage({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  State<HexaShopPage> createState() => _HexaShopPageState();
}

class _HexaShopPageState extends State<HexaShopPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('hexaminate').listenable(),
        builder: (ctx, box, widget) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late Widget widget_app = const Center(
                child: Text("Hello World"),
              );
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
                  child: widget_app,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
