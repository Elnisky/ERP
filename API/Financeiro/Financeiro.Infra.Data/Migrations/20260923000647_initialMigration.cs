using System;
using FirebirdSql.EntityFrameworkCore.Firebird.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Financeiro.Infra.Data.Migrations
{
    /// <inheritdoc />
    public partial class initialMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Cliente",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Fb:ValueGenerationStrategy", FbValueGenerationStrategy.IdentityColumn),
                    Nome = table.Column<string>(type: "VARCHAR(200)", maxLength: 200, nullable: false),
                    Cpf = table.Column<string>(type: "VARCHAR(14)", maxLength: 14, nullable: false),
                    Email = table.Column<string>(type: "VARCHAR(200)", maxLength: 200, nullable: false),
                    Telefone = table.Column<string>(type: "VARCHAR(20)", maxLength: 20, nullable: false),
                    DataCadastro = table.Column<DateTime>(type: "TIMESTAMP", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cliente", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Produto",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Fb:ValueGenerationStrategy", FbValueGenerationStrategy.IdentityColumn),
                    Nome = table.Column<string>(type: "VARCHAR(200)", maxLength: 200, nullable: false),
                    Preco = table.Column<decimal>(type: "DECIMAL(18,2)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    QuantidadeEstoque = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 0)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Produto", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Venda",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Fb:ValueGenerationStrategy", FbValueGenerationStrategy.IdentityColumn),
                    CriadoEm = table.Column<DateTime>(type: "TIMESTAMP", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    PagoEm = table.Column<DateTime>(type: "TIMESTAMP", nullable: true),
                    ClienteId = table.Column<int>(type: "INTEGER", nullable: false),
                    Status = table.Column<short>(type: "SMALLINT", nullable: false, defaultValue: (short)0),
                    Total = table.Column<decimal>(type: "DECIMAL(18,2)", precision: 18, scale: 2, nullable: false, defaultValue: 0m)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Venda", x => x.Id);
                    table.CheckConstraint("CK_VENDA_STATUS", "STATUS BETWEEN 0 AND 3");
                    table.ForeignKey(
                        name: "FK_Venda_Cliente_ClienteId",
                        column: x => x.ClienteId,
                        principalTable: "Cliente",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Pagamento",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Fb:ValueGenerationStrategy", FbValueGenerationStrategy.IdentityColumn),
                    VendaId = table.Column<int>(type: "INTEGER", nullable: false),
                    CriadoEm = table.Column<DateTime>(type: "TIMESTAMP", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    CompletedAt = table.Column<DateTime>(type: "TIMESTAMP", nullable: true),
                    Valor = table.Column<decimal>(type: "DECIMAL(18,2)", precision: 18, scale: 2, nullable: false),
                    Type = table.Column<short>(type: "SMALLINT", nullable: false, defaultValue: (short)0),
                    Status = table.Column<short>(type: "SMALLINT", nullable: false, defaultValue: (short)0),
                    TransacaoId = table.Column<string>(type: "BLOB SUB_TYPE TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Pagamento", x => x.Id);
                    table.CheckConstraint("CK_PAGAMENTO_STATUS", "STATUS BETWEEN 0 AND 2");
                    table.CheckConstraint("CK_PAGAMENTO_TIPO", "TIPO_PAGAMENTO BETWEEN 0 AND 3");
                    table.ForeignKey(
                        name: "FK_Pagamento_Venda_VendaId",
                        column: x => x.VendaId,
                        principalTable: "Venda",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "VendaItem",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Fb:ValueGenerationStrategy", FbValueGenerationStrategy.IdentityColumn),
                    VendaId = table.Column<int>(type: "INTEGER", nullable: false),
                    ProdutoId = table.Column<int>(type: "INTEGER", nullable: false),
                    Quantidade = table.Column<int>(type: "INTEGER", nullable: false, defaultValue: 1),
                    ValorUnitario = table.Column<decimal>(type: "DECIMAL(18,2)", precision: 18, scale: 4, nullable: false, defaultValue: 0m),
                    ValorTotal = table.Column<decimal>(type: "DECIMAL(18,2)", precision: 18, scale: 4, nullable: false, defaultValue: 0m)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VendaItem", x => x.Id);
                    table.ForeignKey(
                        name: "FK_VendaItem_Produto_ProdutoId",
                        column: x => x.ProdutoId,
                        principalTable: "Produto",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_VendaItem_Venda_VendaId",
                        column: x => x.VendaId,
                        principalTable: "Venda",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IDX_PAGAMENTO_STATUS",
                table: "Pagamento",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IDX_PAGAMENTO_VENDA",
                table: "Pagamento",
                column: "VendaId");

            migrationBuilder.CreateIndex(
                name: "IDX_PRODUTO_NOME",
                table: "Produto",
                column: "Nome");

            migrationBuilder.CreateIndex(
                name: "IDX_VENDA_CLIENTE",
                table: "Venda",
                column: "ClienteId");

            migrationBuilder.CreateIndex(
                name: "IDX_VENDA_STATUS",
                table: "Venda",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IDX_VENDAITEM_PRODUTO",
                table: "VendaItem",
                column: "ProdutoId");

            migrationBuilder.CreateIndex(
                name: "IDX_VENDAITEM_VENDA",
                table: "VendaItem",
                column: "VendaId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Pagamento");

            migrationBuilder.DropTable(
                name: "VendaItem");

            migrationBuilder.DropTable(
                name: "Produto");

            migrationBuilder.DropTable(
                name: "Venda");

            migrationBuilder.DropTable(
                name: "Cliente");
        }
    }
}
