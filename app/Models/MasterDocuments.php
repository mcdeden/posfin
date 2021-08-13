<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterDocuments extends Model
{
    protected $table='master_documents';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'documents'
    ];
}
