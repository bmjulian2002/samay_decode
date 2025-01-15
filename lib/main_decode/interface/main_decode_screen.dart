import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:samay_decode/main_decode/domain/main_decode_provider.dart';
import 'package:samay_decode/utils/samay_colors.dart';

class MainDecodeScreen extends StatelessWidget {
  const MainDecodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainDecodeProvider = Provider.of<MainDecodeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SamayColors.blue,
        title: Text(
          'Decodificador Samay',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: mainDecodeProvider.decodeController.value,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Introduce un mensaje codificado',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String input = mainDecodeProvider.decodeController.value.text;
                if (RegExp(r'^\d+$').hasMatch(input)) {
                  mainDecodeProvider.decodedResults.value =
                      mainDecodeProvider.decodeNumber(input);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Por favor, introduce solo números.'),
                  ));
                }
              },
              child: Text(
                'Decodificar',
                style: GoogleFonts.poppins(
                  color: SamayColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Posibles resultados',
              style: GoogleFonts.poppins(
                color: SamayColors.blue,
                fontSize: 25,
              ),
            ),
            Divider(
              height: 50,
              color: SamayColors.blue,
            ),
            Expanded(
              child: mainDecodeProvider.decodedResults.value.isEmpty
                  ? Center(child: Text('No hay resultados.'))
                  : ValueListenableBuilder(
                      valueListenable: mainDecodeProvider.decodedResults,
                      builder: (context, decodedResults, snapshot) {
                        return ListView.builder(
                          itemCount: decodedResults.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: SamayColors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                title: Text(
                                  'Opcion #${index + 1}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  decodedResults[index],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
