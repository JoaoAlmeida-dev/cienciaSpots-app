import 'database/tables/database_spot_table.dart';

class Spot {
  Spot({
    required this.id,
    required this.photoLink,
    required this.description,
    this.visited = false,
    this.puzzleComplete = false,
  });
  final int id;
  final String photoLink;
  final String description;
  bool visited;
  bool puzzleComplete;

  @override
  String toString() {
    return 'Spot{id: $id, photoLink: $photoLink, description: $description, visited: $visited, puzzleComplete: $puzzleComplete}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Spot &&
          id == other.id &&
          photoLink == other.photoLink &&
          description == other.description;

  @override
  int get hashCode => id.hashCode ^ photoLink.hashCode ^ description.hashCode;

  factory Spot.fromMap(Map<String, dynamic> json) => Spot(
        id: json[DatabaseSpotTable.columnId],
        description: json[DatabaseSpotTable.columnName],
        photoLink: json[DatabaseSpotTable.columnPhotoLink],
        visited: json[DatabaseSpotTable.columnVisited] == 1 ? true : false,
        puzzleComplete:
            json[DatabaseSpotTable.columnPuzzleComplete] == 1 ? true : false,
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseSpotTable.columnId: id,
      DatabaseSpotTable.columnName: description,
      DatabaseSpotTable.columnPhotoLink: photoLink,
      DatabaseSpotTable.columnVisited: visited ? 1 : 0,
      DatabaseSpotTable.columnPuzzleComplete: puzzleComplete ? 1 : 0,
    };
  }
}
