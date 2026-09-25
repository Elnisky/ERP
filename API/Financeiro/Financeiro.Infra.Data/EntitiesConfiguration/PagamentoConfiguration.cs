using Financeiro.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.EntitiesConfiguration
{
    public class PagamentoConfiguration : IEntityTypeConfiguration<Pagamento>
    {
        public void Configure(EntityTypeBuilder<Pagamento> builder)
        {
            builder.HasKey(p => p.Id);
            builder.Property(p => p.Valor)
                .IsRequired()
                .HasPrecision(18, 2);
            builder.Property(p => p.CriadoEm)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .IsRequired();
            builder.Property(p => p.Type)
                .HasConversion<int>()
                .HasColumnType("SMALLINT")
                .HasDefaultValue(TipoPagamento.Dinheiro)
                .IsRequired();
            builder.Property(p => p.Status)
                .HasConversion<int>()
                .HasColumnType("SMALLINT")
                .HasDefaultValue(PagamentoStatus.Pendente)
                .IsRequired();
            builder.HasOne(p => p.Venda)
                .WithMany(v => v.Pagamentos)
                .HasForeignKey(p => p.VendaId)
                .OnDelete(DeleteBehavior.Cascade);
            builder.HasIndex(p => p.VendaId)
                .HasDatabaseName("IDX_PAGAMENTO_VENDA");
            builder.HasIndex(p => p.Status)
                .HasDatabaseName("IDX_PAGAMENTO_STATUS");
            builder.HasCheckConstraint("CK_PAGAMENTO_TIPO", "\"Type\" BETWEEN 0 AND 3");
            builder.HasCheckConstraint("CK_PAGAMENTO_STATUS", "\"Status\" BETWEEN 0 AND 2");

        }
    }
}
