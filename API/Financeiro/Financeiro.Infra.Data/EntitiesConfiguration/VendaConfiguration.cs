using Financeiro.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.EntitiesConfiguration
{
    public class VendaConfiguration : IEntityTypeConfiguration<Venda>
    {
        public void Configure(EntityTypeBuilder<Venda> builder)
        {
            builder.HasKey(v => v.Id);
            builder.Property(v => v.ClienteId)
                .IsRequired();
            builder.HasOne(v => v.Cliente)
                .WithMany(c => c.Vendas)
                .HasForeignKey(v => v.ClienteId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.Property(v => v.CriadoEm)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .IsRequired();
            builder.Property(v => v.Status)
                .HasConversion<int>()
                .HasColumnType("SMALLINT")
                .HasDefaultValue(StatusVenda.Orcamento)
                .IsRequired();
            builder.Property(v => v.Total)
                .HasPrecision(18, 2)
                .HasDefaultValue(0)
                .IsRequired();
            builder.HasIndex(v => v.ClienteId)
                .HasDatabaseName("IDX_VENDA_CLIENTE");
            builder.HasIndex(v => v.Status)
                .HasDatabaseName("IDX_VENDA_STATUS");
            builder.HasMany(v => v.VendaItens)
                .WithOne(vi => vi.Venda)
                .HasForeignKey(vi => vi.VendaId)
                .OnDelete(DeleteBehavior.Cascade);
            builder.HasMany(v => v.Pagamentos)
                .WithOne(p => p.Venda)
                .HasForeignKey(p => p.VendaId)
                .OnDelete(DeleteBehavior.Cascade);
            builder.HasCheckConstraint("CK_VENDA_STATUS", "\"Status\" BETWEEN 0 AND 3");
        }
    }
}
