import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/data/services/notification_service.dart';
import 'package:app_controle_leitura/domain/entities/book.dart';
import 'package:app_controle_leitura/domain/repositories/book_repository.dart';
import 'package:app_controle_leitura/domain/repositories/note_repository.dart';
import 'package:app_controle_leitura/domain/repositories/goal_repository.dart';
import 'package:app_controle_leitura/domain/repositories/streak_repository.dart';
import 'package:app_controle_leitura/domain/usecases/book/get_all_books.dart';
import 'package:app_controle_leitura/domain/usecases/goal/get_annual_goal.dart';
import 'package:app_controle_leitura/domain/usecases/goal/set_annual_goal.dart';
import 'package:app_controle_leitura/domain/usecases/book/add_book.dart';
import 'package:app_controle_leitura/domain/usecases/book/delete_book.dart';
import 'package:app_controle_leitura/domain/usecases/book/update_book.dart';
import 'package:app_controle_leitura/domain/usecases/book/mark_as_read.dart';
import 'package:app_controle_leitura/domain/usecases/book/move_to_reading.dart';
import 'package:app_controle_leitura/domain/usecases/book/update_reading_progress.dart';
import 'package:app_controle_leitura/domain/usecases/streak/record_reading_activity.dart';
import 'package:app_controle_leitura/domain/usecases/achievement/check_achievements.dart';
import 'package:app_controle_leitura/core/usecases/usecase.dart';

class MockBookRepository extends Mock implements BookRepository {}

class MockNoteRepository extends Mock implements NoteRepository {}

class MockGoalRepository extends Mock implements GoalRepository {}

class MockStreakRepository extends Mock implements StreakRepository {}

class MockGetAllBooks extends Mock implements GetAllBooks {}

class MockGetAnnualGoal extends Mock implements GetAnnualGoal {}

class MockSetAnnualGoal extends Mock implements SetAnnualGoal {}

class MockAddBook extends Mock implements AddBook {}

class MockDeleteBook extends Mock implements DeleteBook {}

class MockUpdateBook extends Mock implements UpdateBook {}

class MockMarkAsRead extends Mock implements MarkAsRead {}

class MockMoveToReading extends Mock implements MoveToReading {}

class MockUpdateReadingProgress extends Mock implements UpdateReadingProgress {}

class MockRecordReadingActivity extends Mock implements RecordReadingActivity {}

class MockCheckAchievements extends Mock implements CheckAchievements {}

class MockNotificationService extends Mock implements NotificationService {}

// Fallback registrations — call once in setUpAll
void registerFallbacks() {
  registerFallbackValue(BookStatus.wantToRead);
  registerFallbackValue(
    const Book(
      id: 'fallback',
      title: '',
      author: '',
      status: BookStatus.wantToRead,
      totalPages: 0,
    ),
  );
  registerFallbackValue(const NoParams());
  registerFallbackValue(const MarkAsReadParams(id: 'fallback'));
  registerFallbackValue(
      const UpdateReadingProgressParams(bookId: 'fallback', currentPage: 0));
  registerFallbackValue(
      const SetAnnualGoalParams(year: 2024, goal: 0));
  registerFallbackValue(DateTime(2024));
}
