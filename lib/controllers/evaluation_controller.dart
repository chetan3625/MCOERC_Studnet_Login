import 'package:get/get.dart' hide Response;
import '../core/api_service.dart';
import '../models/evaluation_model.dart';
import '../models/admin_model.dart';
import 'admin_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'auth_controller.dart';
import 'package:dio/dio.dart';

class EvaluationController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;
  
  final originality = 0.0.obs;
  final technical = 0.0.obs;
  final presentation = 0.0.obs;
  final impact = 0.0.obs;
  
  final topTeams = [].obs;
  final allTeamsEvaluations = [].obs;
  final message = ''.obs;

  double get totalScore => originality.value + technical.value + presentation.value + impact.value;

  void resetScores() {
    originality.value = 0;
    technical.value = 0;
    presentation.value = 0;
    impact.value = 0;
  }

  Future<void> submitEvaluation(String teamId) async {
    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      
      Scores scores = Scores(
        originality: originality.value,
        technical: technical.value,
        presentation: presentation.value,
        impact: impact.value,
      );

      Map<String, dynamic> payload = {
        'teamId': teamId,
        'scores': scores.toJson(),
        'supervisorId': authController.supervisorId.value,
      };

      Response response = await _apiService.post('/evaluate-team', payload);
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Evaluation submitted successfully');
        Get.offAllNamed('/dashboard');
        resetScores();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['error'] ?? 'Evaluation failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTopTeams() async {
    try {
      isLoading.value = true;
      Response response = await _apiService.get('/top-teams');
      if (response.statusCode == 200) {
        topTeams.value = response.data['topTeams'];
        message.value = response.data['message'] ?? '';
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.message ?? 'Failed to fetch top teams');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllTeamsEvaluations() async {
    try {
      isLoading.value = true;
      Response response = await _apiService.get('/all-teams');
      if (response.statusCode == 200) {
        allTeamsEvaluations.value = response.data['teams'];
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.message ?? 'Failed to fetch all teams');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateAndPrintReceipt() async {
    try {
      isLoading.value = true;
      
      // Ensure we have latest data
      await fetchAllTeamsEvaluations();
      final adminController = Get.find<AdminController>();
      await adminController.fetchAdmins();
      
      final admins = adminController.admins;
      // Sort teams by total score descending
      final sortedTeams = List.from(allTeamsEvaluations);
      sortedTeams.sort((a, b) {
        num scoreA = a['evaluation']?['totalScore'] ?? 0;
        num scoreB = b['evaluation']?['totalScore'] ?? 0;
        return scoreB.compareTo(scoreA);
      });

      final doc = pw.Document();

      // Top 3 Page
      final top3 = sortedTeams.take(3).toList();
      
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Hackathon Result Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Top 3 Performers', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blueAccent)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Rank', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Team Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Total Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...top3.asMap().entries.map((entry) {
                    final index = entry.key;
                    final team = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${index + 1}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(team['teamName'] ?? 'N/A')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${team['evaluation']?['totalScore'] ?? 0} / 50')),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('All Teams Detailed Score Card', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Team Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ...admins.map((admin) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5), 
                        child: pw.Column(
                          children: [
                            pw.Text(admin.name ?? 'Admin', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                              children: [
                                pw.Text('O', style: pw.TextStyle(fontSize: 8)),
                                pw.Text('T', style: pw.TextStyle(fontSize: 8)),
                                pw.Text('P', style: pw.TextStyle(fontSize: 8)),
                                pw.Text('I', style: pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                          ],
                        ),
                      )),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Avg', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  // Data Rows
                  ...sortedTeams.map((team) {
                    final evals = team['evaluation']?['supervisorEvaluations'] ?? {};
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(team['teamName'] ?? 'N/A', style: const pw.TextStyle(fontSize: 9))),
                        ...admins.map((admin) {
                          // Try to find by ID (which is the key in map)
                          // Note: supervisorEvaluations keys might be admin username or ID depending on how it's stored.
                          // Based on backend server.js, supervisorId is passed.
                          final score = evals[admin.id]; 
                          // If not found by ID, maybe it's stored by username (check seedSuperAdmin)
                          final scoreAlt = score ?? evals[admin.username];
                          
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                              children: [
                                pw.Text('${scoreAlt?['originality'] ?? '-'}', style: const pw.TextStyle(fontSize: 8)),
                                pw.Text('${scoreAlt?['technical'] ?? '-'}', style: const pw.TextStyle(fontSize: 8)),
                                pw.Text('${scoreAlt?['presentation'] ?? '-'}', style: const pw.TextStyle(fontSize: 8)),
                                pw.Text('${scoreAlt?['impact'] ?? '-'}', style: const pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                          );
                        }),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${team['evaluation']?['totalScore'] ?? 0}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Legend: O=Originality (10), T=Technical (20), P=Presentation (10), I=Impact (10)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.Footer(
                margin: const pw.EdgeInsets.only(top: 20),
                trailing: pw.Text('Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
