import IndexableArray from "indexable-array";
import Constraint, { ConstraintConstructorArgs } from "../base/constraint";
import Column from "../column";
import { Action, MatchType } from "../../types";
import Table from "../entity/table";
import Index from "..";
import { Schema } from "../..";

/** @ignore */
export interface ForeignKeyConstructorArgs extends ConstraintConstructorArgs {
  onUpdate: Action;
  onDelete: Action;
  matchType: MatchType;
  index: Index;
  columns: Column[];
  table: Table;
}

/**
 * Class which represent a foreign key. Provides attributes and methods for details of the foreign key.
 */
export default class ForeignKey extends Constraint {
  /** @ignore */
  public constructor(args: ForeignKeyConstructorArgs) {
    super(args);

    this.onUpdate = args.onUpdate;
    this.onDelete = args.onDelete;
    this.matchType = args.matchType;
    this.index = args.index;
    this.columns = IndexableArray.throwingFrom(args.columns, "name");
    this.table = args.table;
  }

  /**
   * Match option of {@link ForeignKey}. One of `FULL`, `PARTIAL`, `NONE`. TypeScript developers should use {@link MatchOption} enum.
   */
  public readonly matchType: MatchType;

  /**
   * Update action for {@link ForeignKey foreign keys}. One of `CASCADE`, `SET NULL`, `SET DEFAULT`, `RESTRICT`, `NO ACTION`.
   * TypeScript developers should use {@link Action} enumn.
   */
  public readonly onUpdate: Action;

  /**
   * Delete action for {@link ForeignKey foreign keys}. One of `CASCADE`, `SET NULL`, `SET DEFAULT`, `RESTRICT`, `NO ACTION`.
   * TypeScript developers should use {@link Action} enumn.
   */
  public readonly onDelete: Action;

  /**
   * The @{link Index index}} supporting this constraint.
   */
  public readonly index: Index;

  /**
   * {@link IndexableArray Indexable array} of {@link Column columns} this {@link ForeignKey foreign key} has. {@link Column Columns} are in order their ordinal position
   * within the {@link ForeignKey foreign key}.
   */
  public readonly columns: IndexableArray<Column, "name", never, true>;

  /**
   * This is [[Table]] instance this {@link ForeignKey foreign key} refers to.
   */
  public get referencedTable(): Table {
    return this.index.table;
  }

  /**
   * {@link IndexableArray Indexable array} of {@link Column columns} this {@link ForeignKey foreign key} refers. {@link Column Columns} are in order their ordinal position
   * within the {@link ForeignKey foreign key}.
   */
  public get referencedColumns(): IndexableArray<Column, "name", never, true> {
    return this.index.columns;
  }

  /**
   * Array of columns this {@link ForeignKey foreign key} has and refers to.
   */
  public get referencedColumnsBy(): { column: Column; references: Column }[] {
    return this.columns.mapToArray((column, i) => ({ column, references: this.referencedColumns[i] }));
  }

  /**
   * List of other foreign keys which has same source table and target table.
   */
  public get correspondingForeignKeys(): IndexableArray<ForeignKey, "name", never, true> {
    return this.table.getForeignKeysTo(this.referencedTable).filter((fk) => fk !== this);
  }

  /**
   * {@link Table} which this {@link Constraint constraint} defined in.
   */
  public readonly table: Table;

  /**
   * Full name of the {@link Constraint constraint} including table name.
   */
  public get fullName(): string {
    return `${this.schema.name}.${this.table.name}.${this.name}`;
  }

  /**
   * [[Schema]] of the {@link Constraint constraint}'s table defined in.
   */
  public get schema(): Schema {
    return this.table.schema;
  }
}
